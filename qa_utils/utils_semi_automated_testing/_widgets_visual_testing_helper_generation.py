import os
import sys
from pathlib import Path
import json

from py_utils.comment_content_extractor import first_comment_extraction
from py_utils.file_utils import  get_files_in_directory, create_file_if_necessary_and_add_content
sys.path.append(str(Path(__file__).parent.parent))

eol = os.linesep 

# Time allocated for the webservers to start
time_for_servers_to_start = 70 # 70 for an Core i3, 8 GB

# Getting the project's absolute path from the config file
config_path = "./_qa_utils_config.json"
with open(config_path, 'r') as file:
    config = json.load(file)
projet_root = config.get("projetRoot")

# Data used to build to os-specific part
window_output_file_name = "2_widget_visual_testing_helper.bat"
linux_output_file_name = "4_widget_visual_testing_helper.sh"
macos_output_file_name = "6_widget_visual_testing_helper.zsh"


linux_data = {"chmod":f"# To make the script executable: chmod u+x {linux_output_file_name}", "script_type":"# Bash",
              "after_comment":"",
              "time_to_read_comment":"sleep 5",
              "before_flutter_command":f"xterm -e \"cd {projet_root};", "after_flutter_command":"-d web-server --web-port", 
              "after_web_ports":"\" &","comment_character":"#",
              "time_for_servers_to_start":f"sleep {time_for_servers_to_start}",
              "chrome_tab_begin":"open \"http://localhost:", "chrome_tab_end":"\"",
              "output_file_name":f"{linux_output_file_name}"}

macos_data = {"chmod":f"# To make the script executable: chmod u+x {macos_output_file_name}", "script_type":"# Zsh", 
              "after_comment":"",
              "time_to_read_comment":"sleep 5",
              "before_flutter_command":f"osascript -e 'tell application \"Terminal\" to do script \"cd {projet_root};", 
              "after_flutter_command":"-d web-server --web-port", 
              "after_web_ports":"\"'","comment_character":"#",
              "time_for_servers_to_start":f"sleep {time_for_servers_to_start}",
              "chrome_tab_begin":"open -a \"Google Chrome\" \"http://localhost:", "chrome_tab_end":"\"",
              "output_file_name":f"{macos_output_file_name}"
              }

windows_data = {"chmod":":: Please note that Chrome must be started to have more than one tab launched.", "script_type":":: Batch",
                "after_comment":f'@echo off{eol}'
                f'set BROWSER="C:\Program Files\Google\Chrome\Application\chrome.exe"{eol}',
                "time_to_read_comment":"timeout /t 5 >nul",
                "before_flutter_command":"start ", "after_flutter_command":" -d web-server --web-port ",
                "after_web_ports":"","comment_character":"::",
                "time_for_servers_to_start":f"timeout /t {time_for_servers_to_start} >nul",
                "chrome_tab_begin":"%BROWSER% http://localhost:", "chrome_tab_end":"",
                "output_file_name":f"{window_output_file_name}"}

# used_data = linux_data
# used_data = macos_data
used_data = windows_data



# Defines the relative path to the widgets directory
widgets_dir_path = os.path.join("..", "..","test", "common_widgets")

def main():
    print('')   
    print(f"Searching the widgets in: {widgets_dir_path}")
    print('')

    file_list = get_files_in_directory(
        directory_path=widgets_dir_path, 
        file_extension=".dart", 
        search_is_recursive=True
    )
    print("File paths found:")
    [print(item) for item in file_list]
    
    cmd_lines = (
        f'{used_data["chmod"]}{eol}'
        f'{used_data["script_type"]} file launching the widgets, testing the custom widgets, in Chrome tabs.{eol}'  
        f'{used_data["after_comment"]}'               
        f'cd ../..{eol}'    
        f'echo "After launching the terminals, programm to wait for the web servers to be completely started before opening the browser tabs"{eol}'
        f'{used_data["time_to_read_comment"]}{eol}{eol}'
    )
    
    init_port = 8090
    # Processing each file
    for file in file_list:       
        
        # 1. Extracting the first comment line
        processed_comment = first_comment_extraction(
            file_path=file, 
            delimiter_line="//Line for automated processing"
        )
        
        # 2. Cleaning the extracted line
        # Removing '//' at the start (should happen if extraction is correct)
        processed_comment = processed_comment.strip()
        if processed_comment.startswith('//'):
            processed_comment = processed_comment[2:].strip()
        
        #3 Keeping only until .dart
        try:
            dot_dart_index = processed_comment.index(".dart")
            processed_comment = processed_comment[:dot_dart_index + 5].strip()
        except ValueError:
            print()
            print(f"Error in: {file.name}: '.dart' not found in extracted comment.")
            print()
            sys.exit(1)
            
        # 4. Building the Flutter command
        init_port += 1
        # The command snippet is enclosed in single quotes in osascript
        cmd_flutter_snippet = (
            f"{used_data["before_flutter_command"]} {processed_comment} {used_data["after_flutter_command"]} {init_port}{used_data["after_web_ports"]}{eol}"
        )
        cmd_lines += cmd_flutter_snippet

    # 4. Add server startup timeout and Chrome commands
    cmd_lines += eol
    cmd_lines += f"{used_data["comment_character"]} Waiting for the web servers to start{eol}"
    cmd_lines += f"{used_data["time_for_servers_to_start"]} {eol}"
    
    # init_port holds the final, incremented port number
    start_port = 8091 
    for i in range(start_port, init_port + 1):
        cmd_lines += f'{used_data["chrome_tab_begin"]}{i}{used_data["chrome_tab_end"]}{eol}'

    # 5. Write the final script file
    print("before join")
    file_path_out = os.path.join("..", "..", "qa_utils", "automated_and_semi_automated_tests"
                                 , f"{used_data["output_file_name"]}")
    create_file_if_necessary_and_add_content(file_path=file_path_out, text=cmd_lines)
    print()
    print(f"The file should have been created at {file_path_out}")
    print()
    print(f"{used_data["chmod"]}")

if __name__ == "__main__":
    main()