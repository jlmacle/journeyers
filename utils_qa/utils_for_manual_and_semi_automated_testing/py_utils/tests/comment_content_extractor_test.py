from py_utils.comment_content_extractor import first_comment_extraction

def test_first_comment_extraction():
    file_path = "test/common_widgets/display_and_content/custom_focusable_text_visual_testing.dart"
    delimiter_line = "// Line for automated processing"
    expected = "// flutter run -t ./test/common_widgets/display_and_content/custom_focusable_text_visual_testing.dart -d chrome"
    # strip() to remove /r /n
    assert first_comment_extraction(file_path= file_path, delimiter_line=delimiter_line).strip() == expected