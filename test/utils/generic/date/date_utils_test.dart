import "package:flutter_test/flutter_test.dart";

import "package:journeyers/utils/generic/date/date_utils.dart";

void main() {

  // --- Test Cases for French Date Formats ---

  test("24 janvier 2026 11:58", () {
    String input = "24 janvier 2026 11:58";
    String expected = "24 janvier 2026 11:58";
    expect(DateUtils.sanitizeDate(input), expected);
  });

  test("01 février 2026 09:32", () {
    String input = "01 février 2026 09:32";
    String expected = "01 février 2026 09:32"; 
    expect(DateUtils.sanitizeDate(input), expected);
  });

  test("19 mars 2026 14:38", () {
    String input = "19 mars 2026 14:38";
    String expected = "19 mars 2026 14:38";
    expect(DateUtils.sanitizeDate(input), expected);
  });

  test("04 avril 2026 21:01", () {
    String input = "04 avril 2026 21:01";
    String expected = "04 avril 2026 21:01";
    expect(DateUtils.sanitizeDate(input), expected);
  });

  test("29 mai 2026 11:55", () {
    String input = "29 mai 2026 11:55";
    String expected = "29 mai 2026 11:55";
    expect(DateUtils.sanitizeDate(input), expected);
  });

  test("10 juin 2026 09:22", () {
    String input = "10 juin 2026 09:22";
    String expected = "10 juin 2026 09:22";
    expect(DateUtils.sanitizeDate(input), expected);
  });

  test("02 juillet 2026 14:05", () {
    String input = "02 juillet 2026 14:05";
    String expected = "02 juillet 2026 14:05";
    expect(DateUtils.sanitizeDate(input), expected);
  });

  test("28 août 2026 18:39", () {
    String? input = "28 août 2026 18:39";
    String expected = "28 août 2026 18:39";
    expect(DateUtils.sanitizeDate(input), expected);
  });

  test("09 septembre 2026 05:18", () {
    String input = "09 septembre 2026 05:18";
    String expected = "09 septembre 2026 05:18";
    expect(DateUtils.sanitizeDate(input), expected);
  });

   test("17 octobre 2026 12:44", () {
    String input = "17 octobre 2026 12:44";
    String expected = "17 octobre 2026 12:44";
    expect(DateUtils.sanitizeDate(input), expected);
  });

   test("21 novembre 2026 00:50", () {
    String input = "21 novembre 2026 00:50";
    String expected = "21 novembre 2026 00:50";
    expect(DateUtils.sanitizeDate(input), expected);
  });

   test("05 décembre 2026 19:11", () {
    String input = "05 décembre 2026 19:11";
    String expected = "05 décembre 2026 19:11";
    expect(DateUtils.sanitizeDate(input), expected);
  });

  // --- Test Cases for US English Date Formats ---

  test("January 14, 2026 2:15 PM", () {
    String input = "January 14, 2026 2:15 PM";
    String expected = "January 14, 2026 2:15 PM"; 
    expect(DateUtils.sanitizeDate(input), expected);
  });

  test("February 2, 2026 9:45 AM", () {
    String input = "February 2, 2026 9:45 AM";
    String expected = "February 2, 2026 9:45 AM"; 
    expect(DateUtils.sanitizeDate(input), expected);
  });

  test("March 20, 2026 11:01 PM", () {
    String input = "March 20, 2026 11:01 PM";
    String expected = "March 20, 2026 11:01 PM"; 
    expect(DateUtils.sanitizeDate(input), expected);
  });

  test("April 1, 2026 1:00 AM", () {
    String input = "April 1, 2026 1:00 AM";
    String expected = "April 1, 2026 1:00 AM"; 
    expect(DateUtils.sanitizeDate(input), expected);
  });

  test("May 27, 2026 7:30 AM", () {
    String input = "May 27, 2026 7:30 AM";
    String expected = "May 27, 2026 7:30 AM"; 
    expect(DateUtils.sanitizeDate(input), expected);
  });

  test("June 29, 2026 6:40 PM", () {
    String input = "June 29, 2026 6:40 PM";
    String expected = "June 29, 2026 6:40 PM"; 
    expect(DateUtils.sanitizeDate(input), expected);
  });

  test("July 15, 2026 10:10 AM", () {
    String input = "July 15, 2026 10:10 AM";
    String expected = "July 15, 2026 10:10 AM"; 
    expect(DateUtils.sanitizeDate(input), expected);
  });

  test("August 3, 2026 3:10 AM", () {
    String input = "August 3, 2026 3:10 AM";
    String expected = "August 3, 2026 3:10 AM"; 
    expect(DateUtils.sanitizeDate(input), expected);
  });

  test("September 25, 2026 12:00 PM", () {
    String input = "September 25, 2026 12:00 PM";
    String expected = "September 25, 2026 12:00 PM"; 
    expect(DateUtils.sanitizeDate(input), expected);
  });

  test("October 18, 2026 8:20 PM", () {
    String input = "October 18, 2026 8:20 PM";
    String expected = "October 18, 2026 8:20 PM"; 
    expect(DateUtils.sanitizeDate(input), expected);
  });

  test("November 7, 2026 1:12 AM", () {
    String input = "November 7, 2026 1:12 AM";
    String expected = "November 7, 2026 1:12 AM"; 
    expect(DateUtils.sanitizeDate(input), expected);
  });

  test("December 23, 2026 4:55 AM", () {
    String input = "December 23, 2026 4:55 AM";
    String expected = "December 23, 2026 4:55 AM"; 
    expect(DateUtils.sanitizeDate(input), expected);
  });

  // "September 17, 2026 4:37 PM": a case that happened in the code with a NBSP
  test("September 17, 2026 4:37 PM", () {
    String input = "September 17, 2026 4:37 PM";
    String expected = "September 17, 2026 4:37 PM"; 
    expect(DateUtils.sanitizeDate(input), expected);
  });
  
  // test("should return an empty string when input is null", () {
  //   String? input;
  //   String expected = "";
  //   expect(DateUtils.sanitizeDate(input), expected);
  // });
}
