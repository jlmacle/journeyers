import 'dart:io';

class FileUtils 
{
  Future<void> appendText(File file, String text) async
  {
    try{
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

