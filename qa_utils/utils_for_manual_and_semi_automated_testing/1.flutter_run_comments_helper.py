import os
import logging
from pathlib import Path

def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )


# To add this type of comments to testing widgets:
# (Uses the environment variable JOURNEYERS_DIR to point to the project directory)

# //Line for automated processing
# // flutter run -t ./test/common_widgets/display_and_content/custom_dismissable_rectangular_area_visual_testing.dart -d chrome
# // flutter run -t ./test/common_widgets/display_and_content/custom_dismissable_rectangular_area_visual_testing.dart -d linux
# // flutter run -t ./test/common_widgets/display_and_content/custom_dismissable_rectangular_area_visual_testing.dart -d macos
# // flutter run -t ./test/common_widgets/display_and_content/custom_dismissable_rectangular_area_visual_testing.dart -d windows
# //Line for automated processing
def main():
    setup_logging()
    logger = logging.getLogger("flutter_run_comment_helper")
    eol = "\n"
    project_dir = os.environ.get('JOURNEYERS_DIR', '')
    if not project_dir:
        logger.error("JOURNEYERS_DIR environment variable not set.")
        return

    # Relative file path
    # path on Windows: "test\common_widgets\interaction_and_inputs\custom_checkbox_list_tile_with_text_field_visual_testing.dart"
    # path on macOS: "test/common_widgets/display_and_content/custom_dismissable_rectangular_area_visual_testing.dart"
    # path on Lubuntu: "test/common_widgets/display_and_content/custom_dismissable_rectangular_area_visual_testing.dart"

    # file_path = r"test\common_widgets\display_and_content\custom_dismissable_rectangular_area_visual_testing.dart"
    file_path = "test/common_widgets/display_and_content/custom_dismissable_rectangular_area_visual_testing.dart"
    file_path = file_path.replace("\\", "/")

    comment_begin = "// flutter run -t "
    device_flag = " -d "
    comment_end_chrome = "chrome"
    comment_end_linux = "linux"
    comment_end_macos = "macos"
    comment_end_windows = "windows"

    delimiter_line = "//Line for automated processing"

    full_path = os.path.join(project_dir, file_path) if project_dir else file_path
    file = Path(full_path)

    if not file.exists():
        logger.error(f"File doesn't exist: {file}")
        logger.error(f"Current working directory: {os.getcwd()}")
        return

    try:
        content = file.read_text()
        if delimiter_line in content:
            logger.error(f"The delimiter line was found in {file_path}")
        else:
            logger.info(f"The delimiter line wasn't found in {file_path}")
            logger.info("Addition to the file")

            if not file_path.startswith('./'):
                file_path = f'./{file_path}'

            comment = (
                f"{delimiter_line}{eol}"
                f"{comment_begin}{file_path}{device_flag}{comment_end_chrome}{eol}"
                f"{comment_begin}{file_path}{device_flag}{comment_end_linux}{eol}"
                f"{comment_begin}{file_path}{device_flag}{comment_end_macos}{eol}"
                f"{comment_begin}{file_path}{device_flag}{comment_end_windows}{eol}"
                f"{delimiter_line}{eol}"
            )

            with open(file, 'r+') as f:
                old = f.read()
                f.seek(0)
                f.write(comment + old)

            logger.info("The comments should have been added.")
    except PermissionError as e:
        logger.error(f"PermissionError: {e}")
    except Exception as e:
        logger.error(f"Error: {e}")

if __name__ == "__main__":
    main()
