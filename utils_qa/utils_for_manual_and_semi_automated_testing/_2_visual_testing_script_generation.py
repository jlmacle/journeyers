'''
Script used to generate multi-platform scripts, 
that launch the testing widgets in a web browser after starting a web server.
'''
import os
import sys
import platform

from py_utils.comment_content_extractor import first_comment_extraction
from py_utils.file_utils import  get_files_in_directory, create_file_if_necessary_and_write_content

EOL = os.linesep 

# Time allocated for the webservers to start
TIME_FOR_SERVERS_TO_START = 70 # 70 for an Core i3, 8 GB

# Getting the project's absolute path from the environment variable if necessary
OS_NAME = platform.system().lower()
projet_root = "./" 
if OS_NAME == "darwin":
    projet_root = os.environ.get('JOURNEYERS_DIR', '')

# Data used to build the os-specific script parts
WINDOW_OUTPUT_FILE_NAME = "2_widget_visual_testing_helper.bat"
LINUX_OUTPUT_FILE_NAME = "4_widget_visual_testing_helper.sh"
MACOS_OUTPUT_FILE_NAME = "6_widget_visual_testing_helper.zsh"

system_adapted_data = {}

LINUX_DATA = {"chmod":f"# To make the script executable: chmod u+x {LINUX_OUTPUT_FILE_NAME}", "script_type":"# Bash",
              "after_comment":"",
              "time_to_read_comment":"sleep 5",
              "terminal_command_beginning":f"xterm -e \"cd {projet_root};", "terminal_command_endish":"-d web-server --web-port", 
              "after_web_ports":"\" &","comment_character":"#",
              "time_for_servers_to_start":f"sleep {TIME_FOR_SERVERS_TO_START}",
              "browser_begin":"open \"http://localhost:", "browser_end":"\"",
              "output_file_name":f"{LINUX_OUTPUT_FILE_NAME}"}

MACOS_DATA = {"chmod":f"# To make the script executable: chmod u+x {MACOS_OUTPUT_FILE_NAME}", "script_type":"# Zsh", 
              "after_comment":"",
              "time_to_read_comment":"sleep 5",
              "terminal_command_beginning":f"osascript -e 'tell application \"Terminal\" to do script \"cd {projet_root};", 
              "terminal_command_endish":"-d web-server --web-port", 
              "after_web_ports":"\"'","comment_character":"#",
              "time_for_servers_to_start":f"sleep {TIME_FOR_SERVERS_TO_START}",
              "browser_begin":"open -a \"Google Chrome\" \"http://localhost:", "browser_end":"\"",
              "output_file_name":f"{MACOS_OUTPUT_FILE_NAME}"
              }

WINDOWS_DATA = {"chmod":":: Please note that Chrome must be started to have more than one tab launched.", "script_type":":: Batch",
                "after_comment":f'@echo off{EOL}'
                fr'set BROWSER="C:\Program Files\Google\Chrome\Application\chrome.exe"{EOL}',
                "time_to_read_comment":"timeout /t 5 >nul",
                "terminal_command_beginning":"start ", "terminal_command_endish":" -d web-server --web-port ",
                "after_web_ports":"","comment_character":"::",
                "time_for_servers_to_start":f"timeout /t {TIME_FOR_SERVERS_TO_START} >nul",
                "browser_begin":"%BROWSER% http://localhost:", "browser_end":"",
                "output_file_name":f"{WINDOW_OUTPUT_FILE_NAME}"}


if sys.platform.startswith('linux'):
    system_adapted_data = LINUX_DATA
elif sys.platform.startswith('darwin'):
    system_adapted_data = MACOS_DATA
elif sys.platform.startswith('win'):
    system_adapted_data = WINDOWS_DATA
else:
    print(f'Error: platform not correctly detected: {sys.platform}')
    sys.exit()

# Defining the relative path to the widgets directory
widgets_dir_path = os.path.join("..", "..","test", "widgets", "custom")

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
        f'{system_adapted_data["chmod"]}{EOL}'
        f'{system_adapted_data["script_type"]} file launching the widgets, testing the custom widgets, in Chrome tabs.{EOL}'  
        f'{system_adapted_data["after_comment"]}'               
        f'cd ../..{EOL}'    
        f'echo "After launching the terminals, programm to wait for the web servers to be completely started before opening the browser tabs"{EOL}'
        f'{system_adapted_data["time_to_read_comment"]}{EOL}{EOL}'
    )
    
    port_number = 8090
    # Processing each file
    for file in file_list:       
        
        # 1. Extracting the first comment line
        processed_comment = first_comment_extraction(
            file_path=file, 
            delimiter_line="// Line for automated processing"
        )
        
        # 2. Cleaning the extracted line
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
            
        # 4. Building the terminal commands
        port_number += 1
        cmd_line = (
            f'{system_adapted_data["terminal_command_beginning"]} {processed_comment} {system_adapted_data["terminal_command_endish"]} {port_number}{system_adapted_data["after_web_ports"]}{EOL}'
        )
        cmd_lines += cmd_line

    # 4. Adding server startup timeout and browser commands
    cmd_lines += f'{system_adapted_data["comment_character"]} Waiting for the web servers to start{EOL}'
    cmd_lines += f'{system_adapted_data["time_for_servers_to_start"]} {EOL}'

    start_port = 8091 
    last_port_number = port_number
    for i in range(start_port, last_port_number + 1):
        cmd_lines += f'{system_adapted_data["browser_begin"]}{i}{system_adapted_data["browser_end"]}{EOL}'

    # 5. Writing the final script file
    file_path_out = os.path.join(
        "..", 
        "..", 
        "utils_qa", 
        "scripts_for_automated_and_semi_automated_testing",
        f'{system_adapted_data["output_file_name"]}'
    )
    create_file_if_necessary_and_write_content(file_path=file_path_out, text=cmd_lines)
    print()
    print(f"The file should have been created at {file_path_out}")
    print()
    print(f'{system_adapted_data["chmod"]}')

if __name__ == "__main__":
    main()