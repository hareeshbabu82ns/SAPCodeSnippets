REPORT test.

TYPES: BEGIN OF ty_sample_data,
         name   TYPE string,
         amount TYPE string,
       END OF ty_sample_data.

DATA: lt_data TYPE STANDARD TABLE OF ty_sample_data,
      ls_data TYPE ty_sample_data.

DATA: lt_stext TYPE STANDARD TABLE OF tline, "original text
      lt_text  TYPE STANDARD TABLE OF tline, "temporary text table
      ls_text  TYPE tline.

START-OF-SELECTION.
  "fetch data from DB
  ls_data-name = 'John'.
  ls_data-amount = '333.33'.
  APPEND ls_data TO lt_data.

  ls_data-name = 'Doe'.
  ls_data-amount = '444.44'.
  APPEND ls_data TO lt_data.

END-OF-SELECTION.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
*     CLIENT                  = SY-MANDT
      id                      = 'ST'
      language                = sy-langu
      name                    = 'ZH_SO_TEST'
      object                  = 'TEXT'
*     ARCHIVE_HANDLE          = 0
*     LOCAL_CAT               = ' '
*   IMPORTING
*     HEADER                  =
*     OLD_LINE_COUNTER        =
    TABLES
      lines                   = lt_stext
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  DATA: lv_endline TYPE i.
  lv_endline = lines( lt_stext ).

  "loop through the data to be replaced into SO Text
  LOOP AT lt_data INTO ls_data.
    CLEAR: lt_text.
    APPEND LINES OF lt_stext TO lt_text.

    CALL FUNCTION 'SET_TEXTSYMBOL'
      EXPORTING
        name  = '&v_name&'
        value = ls_data-name.

    CALL FUNCTION 'SET_TEXTSYMBOL'
      EXPORTING
        name  = '&v_amount&'
        value = ls_data-amount.

    CALL FUNCTION 'SET_TEXTSYMBOL'
      EXPORTING
        name  = '&v_sender&'
        value = 'Hareesh'.

* Replace text

    CALL FUNCTION 'REPLACE_TEXTSYMBOL'
      EXPORTING
        startline = 1
        endline   = lv_endline
      TABLES
        lines     = lt_text.

* variables in the SO text would have been replaced
    LOOP AT lt_text INTO ls_text.
      WRITE:/ ls_text-tdline.
    ENDLOOP.


  ENDLOOP.
