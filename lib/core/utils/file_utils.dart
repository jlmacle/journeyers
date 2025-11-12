import 'dart:io';

class FileUtils 
{
  Future<void> appendText(String filePath, String text) async
  {
    try{
      var file = File(filePath);
      var sink = file.openWrite(mode: FileMode.append);
      sink.write(text);
      await sink.flush();
      await sink.close();
    }
    on FileSystemException catch (e)
    {
      print('Error appending text to file: ${e.message}');
    }
    catch(e)
    {
      print('Error appending text to file: $e');
    }
  }

}

