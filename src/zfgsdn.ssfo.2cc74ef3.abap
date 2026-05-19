DATA : lines    TYPE STANDARD TABLE OF tline,
       ls_lines LIKE LINE OF lines,
       name     LIKE  thead-tdname.

CASE gt_head-bukrs.
  WHEN '8020'.
    name = 'ZREKPTT'.
  WHEN '8070'.
    name = 'ZREKSUT'.
  WHEN OTHERS.
    name = 'ZREKPTT'.
ENDCASE.

CALL FUNCTION 'READ_TEXT'
  EXPORTING
    id                      = 'ST'
    language                = sy-langu
    name                    = name
    object                  = 'TEXT'
  TABLES
    lines                   = lines
  EXCEPTIONS
    id                      = 1
    language                = 2
    name                    = 3
    not_found               = 4
    object                  = 5
    reference_check         = 6
    wrong_access_to_archive = 7
    OTHERS                  = 8.

LOOP AT lines INTO ls_lines.
  CASE sy-tabix.
    WHEN 1.
      gv_text1  = ls_lines-tdline.
    WHEN 2.
      gv_text2  = ls_lines-tdline.
    WHEN 3.
      gv_text3  = ls_lines-tdline.
  ENDCASE.
ENDLOOP.


















