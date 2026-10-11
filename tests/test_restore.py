import importlib.machinery
import importlib.util
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
loader = importlib.machinery.SourceFileLoader('cloud_restore_fixture', str(ROOT/'bin/omarchy-cloud-sync'))
spec = importlib.util.spec_from_loader(loader.name, loader)
cloud = importlib.util.module_from_spec(spec)
loader.exec_module(cloud)

class RestoreTests(unittest.TestCase):
    def config(self, home):
        return {'remote': 'fixture', 'remote_root': 'Backup', 'exclude_patterns': [], 'folders': [
            {'enabled': True, 'type': 'directory', 'path': str(home/'custom'), 'remote_subpath': 'custom/files'}]}

    def test_plan_is_read_only(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            with patch.object(cloud, 'load_config', return_value=self.config(home)), patch.object(Path, 'home', return_value=home), patch.object(cloud.subprocess, 'run') as run:
                plan = cloud.execute_restore(dry_run=True)
                run.assert_not_called()
            self.assertEqual(plan['destinations'][0]['destination'], str(home/'custom'))
            self.assertFalse(list(home.iterdir()))

    def test_custom_mapping_filters_and_recovery(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder); target = home/'custom/preferences'
            target.parent.mkdir(); target.write_text('old'); target.chmod(0o640)
            def download(command, **kwargs):
                self.assertIn('rclone.conf', command)
                staged = Path(command[3])/'custom/files'; staged.mkdir(parents=True)
                (staged/'preferences').write_text('new')
                (staged/'credentials.json').write_text('excluded')
            with patch.object(cloud, 'load_config', return_value=self.config(home)), patch.object(Path, 'home', return_value=home), patch.object(cloud.subprocess, 'run', side_effect=download):
                result = cloud.execute_restore()
            self.assertEqual(target.read_text(), 'new')
            self.assertEqual(target.stat().st_mode & 0o777, 0o640)
            self.assertFalse((target.parent/'credentials.json').exists())
            self.assertEqual((Path(result['recovery'])/'files/custom/preferences').read_text(), 'old')

    def test_partial_failure_rolls_back(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder); target = home/'custom/a'
            target.parent.mkdir(); target.write_text('old')
            def download(command, **kwargs):
                staged = Path(command[3])/'custom/files'; staged.mkdir(parents=True)
                (staged/'a').write_text('new'); (staged/'b').write_text('new')
            replace = os.replace
            def fail_second(source, destination):
                if Path(destination).name == 'b': raise OSError('fixture write failure')
                return replace(source, destination)
            with patch.object(cloud, 'load_config', return_value=self.config(home)), patch.object(Path, 'home', return_value=home), patch.object(cloud.subprocess, 'run', side_effect=download), patch.object(cloud.os, 'replace', side_effect=fail_second):
                with self.assertRaises(OSError): cloud.execute_restore()
            self.assertEqual(target.read_text(), 'old')
            self.assertFalse((home/'custom/b').exists())

    def test_failed_download_never_changes_destination(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder); target = home/'custom/a'; target.parent.mkdir(); target.write_text('old')
            with patch.object(cloud, 'load_config', return_value=self.config(home)), patch.object(Path, 'home', return_value=home), patch.object(cloud.subprocess, 'run', side_effect=subprocess.CalledProcessError(1, 'fixture')):
                with self.assertRaises(subprocess.CalledProcessError): cloud.execute_restore()
            self.assertEqual(target.read_text(), 'old')

if __name__ == '__main__': unittest.main(verbosity=2)
