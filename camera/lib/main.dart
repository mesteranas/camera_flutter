import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'settings.dart';
import 'package:flutter/widgets.dart';

import 'language.dart';
import 'package:http/http.dart' as http;
import 'viewText.dart';
import 'app.dart';
import 'contectUs.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async{
  await WidgetsFlutterBinding.ensureInitialized();
  await Language.runTranslation();
  runApp(test());
}
class test extends StatefulWidget{
  const test({Key?key}):super(key:key);
  @override
  State<test> createState()=>_test();
}
class _test extends State<test>{
  var paused=false;
  int selectedCamera=0;
  List<CameraDescription> ?cameras;
  CameraController? controler;
  var isFlash=false;
  var isRecording=false;
  var _=Language.translate;
  _test();
  Future <void> setupCamera() async{
    await Permission.storage.request();
    cameras=await availableCameras();
    controler=CameraController(cameras![selectedCamera], ResolutionPreset.high);
    controler!.initialize();
    setState(() {

    });
  }
  void initState(){
    super.initState();
    setupCamera();
  }
  @override
  void dispose(){
    controler!.dispose();
    super.dispose();
  }
  Widget build(BuildContext context){
    return MaterialApp(
      locale: Locale(Language.languageCode),
      title: App.name,
      themeMode: ThemeMode.system,
      home:Builder(builder:(context) 
    =>Scaffold(
      appBar:AppBar(
        title: const Text(App.name),
        actions: [
          IconButton(onPressed: (){
            var flash=FlashMode.auto;
            if (isFlash){
              flash=FlashMode.off;
            } else{
              flash=FlashMode.torch;
            }
            isFlash=!isFlash;
            controler!.setFlashMode(flash);
            setState(() {
              
            });
          }, icon: Icon(isFlash?Icons.flash_on:Icons.flash_off),tooltip: isFlash?_("turn flash off"):_("turn flash on"),),
          IconButton(onPressed: (){
            if (selectedCamera==cameras!.length-1){
              selectedCamera=0;
            } else{
              selectedCamera+=1;
            }
            setupCamera();
            setState(() {
              
            });
          }, icon: Icon(Icons.switch_camera),tooltip:_("switch camera") ,),
                    if (!paused&&isRecording)
          IconButton(onPressed: () async{
            await controler!.pauseVideoRecording();
            setState(() {
              paused=true;
            });
          }, icon: Icon(Icons.pause),tooltip: _("pause"),),
          if (paused&&isRecording)
          IconButton(onPressed: () async{
            await controler!.resumeVideoRecording();
            setState(() {
              paused=false;
            });
          }, icon: Icon(Icons.videocam),tooltip: _("resume"),),
          if (isRecording)
          IconButton(onPressed: () async{
            final video=await controler!.stopVideoRecording();
                        final dir=await getExternalStorageDirectory();
            await video.saveTo(dir!.path+ DateTime.now().microsecondsSinceEpoch.toString() + ".mp4");
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_("video taken") + video.path)));
            setState(() {
              isRecording=false;
              paused= false;
            });


          }, icon: Icon(Icons.stop),tooltip: _("stop"),)
          else
          IconButton(onPressed: () async{

            setState(() {
              isRecording=true;
            });
                        await controler!.startVideoRecording();
          }, icon: Icon(Icons.videocam),tooltip: _("record"),),

        ],), 
        
        drawer: Drawer(
          child:ListView(children: [
          DrawerHeader(child: Text(_("navigation menu"))),
          ListTile(title:Text(_("settings")) ,onTap:() async{
            await Navigator.push(context, MaterialPageRoute(builder: (context) =>SettingsDialog(this._) ));
            setState(() {
              
            });
          } ,),
          ListTile(title: Text(_("contect us")),onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ContectUsDialog(this._)));
          },),
          ListTile(title: Text(_("donate")),onTap: (){
            launch("https://www.paypal.me/AMohammed231");
          },),
  ListTile(title: Text(_("visite project on github")),onTap: (){
    launch("https://github.com/mesteranas/"+App.appName);
  },),
  ListTile(title: Text(_("license")),onTap: ()async{
    String result;
    try{
    http.Response r=await http.get(Uri.parse("https://raw.githubusercontent.com/mesteranas/" + App.appName + "/main/LICENSE"));
    if ((r.statusCode==200)) {
      result=r.body;
    }else{
      result=_("error");
    }
    }catch(error){
      result=_("error");
    }
    Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewText(_("license"), result)));
  },),
  ListTile(title: Text(_("about")),onTap: (){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(title: Text(_("about")+" "+App.name),content:Center(child:Column(children: [
        ListTile(title: Text(_("version: ") + App.version.toString())),
        ListTile(title:Text(_("developer:")+" mesteranas")),
        ListTile(title:Text(_("description:") + App.description))
      ],) ,));
    });
  },)
        ],) ,),
        body:Container(alignment: Alignment.center
        ,child: Column(children: [
          CameraPreview(controler!),
          IconButton(onPressed: () async{
            final image=await controler!.takePicture();
            final dir=await getExternalStorageDirectory();
            await image.saveTo(dir!.path+ DateTime.now().microsecondsSinceEpoch.toString() + ".jbg");
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_("picture taken") + image.path)));
          }, icon: Icon(Icons.camera),tooltip:_("take photo"),),
          

    ])),)));
  }
}
