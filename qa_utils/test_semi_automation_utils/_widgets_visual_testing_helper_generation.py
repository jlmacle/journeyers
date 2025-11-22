import os
import sys
from pathlib import Path
import json

from py_utils.comment_content_extractor import first_comment_extraction
from py_utils.file_utils import  get_files_in_directory, create_file_if_necessary_and_add_content
sys.path.append(str(Path(__file__).parent.parent))

eol = os.linesep 

# Time allocated for the webservers to start
time_for_servers_to_start = 70 # Core i3, 8 GB

# Data used to build to os-specific part
linux_data = {"chmod":"# chmod u+x 4_widget_visual_testing_helper.sh", "script_type":"Bash", "time_to_read_comment":"sleep 5",
              "before_flutter_command":"", "after_flutter_command":"", "time_for_servers_to_start":"",
              "chrome_tab_begin":"", "chrome_tab_end":""}

macos_data = {"chmod":"# chmod u+x 6_widget_visual_testing_helper.zsh", "script_type":"Zsh", "time_to_read_comment":"sleep 5",
              "before_flutter_command":"osascript -e 'tell application \"Terminal\" to do script \""
              , "after_flutter_command":"-d web-server --web-port", "time_for_servers_to_start":f"sleep {time_for_servers_to_start}",
              "chrome_tab_begin":"open -a \"Google Chrome\" \"http://localhost:", "chrome_tab_end":"\""
              }

windows_data = {"chmod":"", "script_type":"Batch", "time_to_read_comment":"timeout /t 5 >nul",
              "before_flutter_command":"", "after_flutter_command":"", "time_for_servers_to_start":"",
              "chrome_tab_begin":"", "chrome_tab_end":""}

used_data = macos_data

# Defines the relative path to the widgets directory
widgets_dir_path = os.path.join("..", "..","test", "common_widgets")

# Getting the project's absolute path from the config file
config_path = "./_qa_utils_config.json"
with open(config_path, 'r') as file:
    config = json.load(file)
projet_root = config.get("projetRoot")

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
        f'# {used_data["script_type"]} file launching the widgets, testing the custom widgets, in Chrome tabs.{eol}'                 
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
            f"{used_data["before_flutter_command"]}cd {projet_root};{processed_comment} {used_data["after_flutter_command"]} {init_port}\"'{eol}"
        )
        cmd_lines += cmd_flutter_snippet

    # 4. Add server startup timeout and Chrome commands
    cmd_lines += eol
    cmd_lines += f"# Waiting for the web servers to start{eol}"
    cmd_lines += f"{used_data["time_for_servers_to_start"]} {eol}"
    
    # init_port holds the final, incremented port number
    start_port = 8091 
    for i in range(start_port, init_port + 1):
        cmd_lines += f'{used_data["chrome_tab_begin"]}{i}{used_data["chrome_tab_end"]}{eol}'

    # 5. Write the final Zsh script file
    file_path_out = os.path.join("..", "..", "qa_utils", "automated_and_semi_automated_tests", "6_widget_visual_testing_helper.zsh")
    create_file_if_necessary_and_add_content(file_path=file_path_out, text=cmd_lines)
    print()
    print(f"The file should have been created at {file_path_out}")
    print()
    print("Please run the following command to make the script executable.")
    print("chmod u+x 6_widget_visual_testing_helper.zsh")
    print()

if __name__ == "__main__":
    main()