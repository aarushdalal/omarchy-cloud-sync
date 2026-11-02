"""Exercise real dashboard navigation with inert cards, then compile all real cards.
No sync, focus, power, media or authentication action is invoked.
"""
from pathlib import Path
import os,shutil,subprocess,tempfile,sys,json,re
origin=Path(sys.argv[1]);entry=sys.argv[2];count=int(sys.argv[3]);evidence=Path(sys.argv[4]);evidence.mkdir(parents=True,exist_ok=True)
with tempfile.TemporaryDirectory(prefix='desktop-consistency-') as tmp:
 p=Path(tmp)
 for name in ['Commons','Ui']:
  shutil.copytree(Path.home()/'.local/share/omarchy/shell'/name,p/name,ignore=shutil.ignore_patterns('*.bak'))
 shutil.copytree(origin/'components',p/'components');shutil.copytree(origin/'cards',p/'cards');shutil.copytree(origin/'services',p/'services');shutil.copy2(origin/entry,p/'Dashboard.qml')
 # Real native host + real cards, hidden and detached from user services.
 (p/'shell.qml').write_text('''import QtQuick
import Quickshell
ShellRoot {
 QtObject {id:bar;property string position:"top";property int barSize:36;property var activePopout:null;property color barForeground:"white";property string fontFamily:"monospace";function requestPopout(x){}function releasePopout(x){}}
 Dashboard {bar:bar;anchorItem:null;open:false}
 Timer {interval:500;running:true;onTriggered:{console.log("NATIVE-COMPILE-PASS");Qt.quit()}}
}''')
 env=dict(os.environ,QT_QPA_PLATFORM='offscreen',QT_QUICK_BACKEND='software',XDG_CACHE_HOME=str(p/'cache'));env.pop('WAYLAND_DISPLAY',None)
 native_env=dict(os.environ,XDG_CACHE_HOME=str(p/'native-cache'));native_env.pop('QT_QPA_PLATFORM',None)
 r=subprocess.run(['quickshell','--no-color','--path',str(p)],capture_output=True,text=True,env=native_env,timeout=15);log=r.stdout+r.stderr;(evidence/'native.log').write_text(log)
 assert r.returncode==0 and 'NATIVE-COMPILE-PASS' in log and 'ERROR' not in log,log
 (p/'qs').mkdir()
 for name in ['Commons','Ui']:(p/'qs'/name).symlink_to(p/name,target_is_directory=True)
 # Inert providers for isolated interaction; native test above uses real providers.
 shutil.rmtree(p/'Commons');(p/'Commons').mkdir()
 (p/'Commons/qmldir').write_text('module qs.Commons\nsingleton Motion 1.0 Motion.qml\nsingleton Style 1.0 Style.qml\nsingleton Color 1.0 Color.qml\nsingleton Border 1.0 Border.qml\n')
 (p/'Commons/Motion.qml').write_text('''pragma Singleton
import QtQuick
QtObject {property bool reducedMotion:false;property string activePreset:"tokyo";property string intensity:"balanced";property int micro:85;property int standard:175;property int expressive:240;property int entryDuration:280;property int easeMicro:Easing.OutQuad;property int easeStandard:Easing.OutCubic;property int easeExpressive:Easing.OutCubic;property real springOvershoot:.7;property real entryScaleStart:.9;property real entryYOffset:16;property real pressScale:.97;property real hoverScale:1.025;property int liquidMoveDuration:240;function calculateOrigin(a,r,p){return {originX:.5,originY:0}}}''')
 (p/'Commons/Style.qml').write_text('''pragma Singleton
import QtQuick
QtObject {property int cornerRadius:10;property var font:({family:"monospace",title:16,bodySmall:12,caption:11});function space(x){return x}}''')
 (p/'Commons/Color.qml').write_text('''pragma Singleton
import QtQuick
QtObject {property color foreground:"#dededb";property color accent:"#8ea0b4"}''')
 (p/'Commons/Border.qml').write_text('''pragma Singleton
import QtQuick
QtObject {function none(){return {type:"none"}}}''')
 shutil.rmtree(p/'Ui');(p/'Ui').mkdir();(p/'Ui/qmldir').write_text('module qs.Ui\n')
 (p/'Dashboard.qml').write_text((p/'Dashboard.qml').read_text().replace('import qs.Ui\n',''))
 # Host adaptation only for interaction; no compositor input grab. Actual controls/page code retained.
 (p/'components/polish/RefinedKeyboardPanel.qml').write_text('''import QtQuick
Item {
 id:root;property var anchorItem:null;property var bar:null;property var owner:null;property bool open:true;property int contentWidth:560;property int contentHeight:488;property var borderSpec:null;property var focusTarget:null
 width:contentWidth;height:contentHeight
 function close(){open=false}
}''')
 for card in (p/'cards').glob('*.qml'):
  card.write_text('''import QtQuick
Item {property var syncService:null;property var focusService:null;property var dashboard:null;function open(path){}implicitHeight:320}''')
 test='''import QtQuick
import QtTest
import qs.Commons
TestCase {
 name:"DashboardConsistency";width:640;height:600;visible:true;when:windowShown
 Dashboard {id:d;open:true}
 function test_navigation_and_motion(){
  let tabs=findChild(d,"dashboard-tabs");verify(tabs!==null);compare(tabs.tabs.length,COUNT)
  for(let i=0;i<COUNT;i++){
   let tab=findChild(tabs,"dashboard-tab-"+i);verify(tab!==null);mouseClick(tab);compare(d.activeTabIndex,i)
   wait(240)
  }
  let last=findChild(tabs,"dashboard-tab-"+(COUNT-1));last.forceActiveFocus();keyClick(Qt.Key_Right);compare(d.activeTabIndex,0)
  keyClick(Qt.Key_End);compare(d.activeTabIndex,COUNT-1);keyClick(Qt.Key_Home);compare(d.activeTabIndex,0)
  d.lastTriggerTime=0;d.handleWheel(-120,true);compare(d.activeTabIndex,1)
  d.lastTriggerTime=0;d.handleWheel(120,true);compare(d.activeTabIndex,0)
  Motion.reducedMotion=true;d.activeTabIndex=COUNT-1;wait(5)
  let pages=[];function walk(x){if(x.pageIndex!==undefined && x.selectedIndex!==undefined)pages.push(x);for(let c of x.children)walk(c)}walk(d)
  compare(pages.length,COUNT)
  for(let page of pages){verify(!page.motionRunning);compare(page.opacity,page.selected?1:0);compare(page.enabled,page.selected)}
  d.open=false;wait(5);for(let page of pages)verify(!page.enabled)
 }
}
'''.replace('COUNT',str(count))
 (p/'tst_consistency.qml').write_text(test)
 r=subprocess.run(['/usr/lib/qt6/bin/qmltestrunner','-input',str(p/'tst_consistency.qml'),'-import',str(p)],capture_output=True,text=True,env=env,timeout=15);log=r.stdout+r.stderr;(evidence/'interaction.log').write_text(log)
 assert r.returncode==0,log
 print(entry, 'native real-card compilation and navigation/reduced-motion tests PASS')
