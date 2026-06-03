*&---------------------------------------------------------------------*
*&  Include           ZSSUT_I010_F01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
 FORM user_ok_tc USING    p_tc_name TYPE dynfnam
                          p_table_name
                          p_mark_name
                 CHANGING p_ok      LIKE sy-ucomm.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA: l_ok              TYPE sy-ucomm,
         l_offset          TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
   SEARCH p_ok FOR p_tc_name.
   IF sy-subrc <> 0.
     EXIT.
   ENDIF.
   l_offset = STRLEN( p_tc_name ) + 1.
   l_ok = p_ok+l_offset.
*&SPWIZARD: execute general and TC specific operations                 *
   CASE l_ok.
     WHEN 'INSR'.                      "insert row
       IF gv_edit = 'X'.
         PERFORM fcode_insert_row USING    p_tc_name
                                           p_table_name.
         CLEAR p_ok.
       ENDIF.
     WHEN 'DELE'.                      "delete row
       PERFORM fcode_delete_row USING    p_tc_name
                                         p_table_name
                                         p_mark_name.
       CLEAR p_ok.

     WHEN 'P--' OR                     "top of list
          'P-'  OR                     "previous page
          'P+'  OR                     "next page
          'P++'.                       "bottom of list
       PERFORM compute_scrolling_in_tc USING p_tc_name
                                             l_ok.
       CLEAR p_ok.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
     WHEN 'MARK'.                      "mark all filled lines
       PERFORM fcode_tc_mark_lines USING p_tc_name
                                         p_table_name
                                         p_mark_name   .
       CLEAR p_ok.

     WHEN 'DMRK'.                      "demark all filled lines
       PERFORM fcode_tc_demark_lines USING p_tc_name
                                           p_table_name
                                           p_mark_name .
       CLEAR p_ok.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

   ENDCASE.

 ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
 FORM fcode_insert_row
               USING    p_tc_name           TYPE dynfnam
                        p_table_name             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA l_lines_name       LIKE feld-name.
   DATA l_selline          LIKE sy-stepl.
   DATA l_lastline         TYPE i.
   DATA l_line             TYPE i.
   DATA l_table_name       LIKE feld-name.
   FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
   FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
   FIELD-SYMBOLS <lines>              TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
   CONCATENATE 'G_' p_tc_name '_LINES' INTO l_lines_name.
   ASSIGN (l_lines_name) TO <lines>.

*&SPWIZARD: get current line                                           *
   GET CURSOR LINE l_selline.
   IF sy-subrc <> 0.                   " append line to table
     l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line                                               *
     IF l_selline > <lines>.
       <tc>-top_line = l_selline - <lines> + 1 .
     ELSE.
       <tc>-top_line = 1.
     ENDIF.
   ELSE.                               " insert line into table
     l_selline = <tc>-top_line + l_selline - 1.
     l_lastline = <tc>-top_line + <lines> - 1.
   ENDIF.
*&SPWIZARD: set new cursor line                                        *
   l_line = l_selline - <tc>-top_line + 1.

*&SPWIZARD: insert initial line                                        *
   INSERT INITIAL LINE INTO <table> INDEX l_selline.
   <tc>-lines = <tc>-lines + 1.
*&SPWIZARD: set cursor                                                 *
   SET CURSOR LINE l_line.

 ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
 FORM fcode_delete_row
               USING    p_tc_name           TYPE dynfnam
                        p_table_name
                        p_mark_name   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA l_table_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <wa>.
   FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
   DESCRIBE TABLE <table> LINES <tc>-lines.

   LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

     IF <mark_field> = 'X'.
       DELETE <table> INDEX syst-tabix.
       IF sy-subrc = 0.
         <tc>-lines = <tc>-lines - 1.
       ENDIF.
     ENDIF.
   ENDLOOP.

 ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
 FORM compute_scrolling_in_tc USING    p_tc_name
                                       p_ok.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA l_tc_new_top_line     TYPE i.
   DATA l_tc_name             LIKE feld-name.
   DATA l_tc_lines_name       LIKE feld-name.
   DATA l_tc_field_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <lines>      TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.
*&SPWIZARD: get looplines of TableControl                              *
   CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
   ASSIGN (l_tc_lines_name) TO <lines>.


*&SPWIZARD: is no line filled?                                         *
   IF <tc>-lines = 0.
*&SPWIZARD: yes, ...                                                   *
     l_tc_new_top_line = 1.
   ELSE.
*&SPWIZARD: no, ...                                                    *
     CALL FUNCTION 'SCROLLING_IN_TABLE'
          EXPORTING
               entry_act             = <tc>-top_line
               entry_from            = 1
               entry_to              = <tc>-lines
               last_page_full        = 'X'
               loops                 = <lines>
               ok_code               = p_ok
               overlapping           = 'X'
          IMPORTING
               entry_new             = l_tc_new_top_line
          EXCEPTIONS
*              NO_ENTRY_OR_PAGE_ACT  = 01
*              NO_ENTRY_TO           = 02
*              NO_OK_CODE_OR_PAGE_GO = 03
               OTHERS                = 0.
   ENDIF.

*&SPWIZARD: get actual tc and column                                   *
   GET CURSOR FIELD l_tc_field_name
              AREA  l_tc_name.

   IF syst-subrc = 0.
     IF l_tc_name = p_tc_name.
*&SPWIZARD: et actual column                                           *
       SET CURSOR FIELD l_tc_field_name LINE 1.
     ENDIF.
   ENDIF.

*&SPWIZARD: set the new top line                                       *
   <tc>-top_line = l_tc_new_top_line.


 ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
 FORM fcode_tc_mark_lines USING p_tc_name
                                p_table_name
                                p_mark_name.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
   DATA l_table_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <wa>.
   FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
   LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

     <mark_field> = 'X'.
   ENDLOOP.
 ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
 FORM fcode_tc_demark_lines USING p_tc_name
                                  p_table_name
                                  p_mark_name .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA l_table_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <wa>.
   FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
   LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

     <mark_field> = space.
   ENDLOOP.
 ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
 FORM f_get_data .
   DATA: lv_dname TYPE char3,
         lv_week TYPE char1.
   DATA: lv_fname TYPE char15.
   DATA: lt_022 TYPE TABLE OF zssutdt022 WITH HEADER LINE.
   DATA: lv_num4 TYPE num4.
   DATA: lt_kna1 TYPE TABLE OF kna1 WITH HEADER LINE,
         lt_knvp TYPE TABLE OF knvp WITH HEADER LINE.

   FIELD-SYMBOLS: <fs>.
   " __* title
   tvkot-vkorg = p_vkorg.
   SELECT SINGLE vtext FROM tvkot INTO tko WHERE vkorg = p_vkorg AND spras = 'E'.
   MOVE tko TO gs_header-company.
   tvkbt-vkbur = p_vkbur.
   SELECT SINGLE bezei FROM tvkbt INTO tkb WHERE vkbur = p_vkbur AND spras = 'E'.
   MOVE tkb TO gs_header-cabang.
   knvp-pernr  = p_pernr.
   SELECT SINGLE cname FROM pa0002 INTO tpe WHERE pernr = p_pernr.
   zssutdt021-begda = p_datum.
   gs_header-tanggal = p_datum.
   PERFORM f_get_dayname USING p_datum 'FULL' CHANGING gs_header-hari.
   MOVE tpe TO gs_header-nama_salesman.
   MOVE p_pernr TO gs_header-kode_salesman.

   SELECT SINGLE atx INTO gv_atx
     FROM t542t AS a JOIN pa0001 AS b ON b~ansvh = a~ansvh AND
                                         b~pernr = knvp-pernr
     WHERE spras = sy-langu
       AND molga = '34'.

   " __* get matrix visitation master data
   SELECT *  INTO CORRESPONDING FIELDS OF  TABLE gt_022
     FROM zssutdt022  AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
     WHERE vkorg = p_vkorg
            AND   kunn2 EQ p_kunn2
**            AND   kunn2 IN s_kunn2
            AND   pernr = p_pernr
            AND   vkbur = p_vkbur
            AND   aufsd = space.
   IF sy-subrc <> 0.
     gv_error = 1.
     RETURN.
   ELSE.
     DELETE gt_022[] WHERE kunn2 EQ space.
     gt_022m[]  = gt_022[].
   ENDIF.
   " __* get data from daily Call plan table

   SELECT SINGLE * FROM zssutdt025 WHERE vkorg = p_vkorg
                                     AND vkbur = p_vkbur
                                     AND pernr = p_pernr
                                     AND sdate = p_datum
                                     AND status NE 'D'.
   "and ZRELEASE ne 'X'.
   IF sy-subrc = 0.
     " __* DATA ALREADY EXIST in ZSSUTDT025/ZSSUTDT026, DISPLAY IT IN TABLE CONTROL!
     gv_mode = 'UPD'.

     CLEAR: lv_answer.
     CONCATENATE 'Sales Office' p_vkbur 'DCP No'  s_dcp-low ' Akan diupdate' INTO gv_message SEPARATED BY space.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
         titlebar              = 'PERHATIAN'
         text_question         = gv_message
         text_button_1         = 'Yes'
         icon_button_1         = 'ICON_CHECKED'
         text_button_2         = 'No'
         icon_button_2         = 'ICON_CANCEL'
         display_cancel_button = ' '
       IMPORTING
         answer                = lv_answer
       EXCEPTIONS
         text_not_found        = 1
         OTHERS                = 2.
     IF sy-subrc = 0.
       IF lv_answer = '1'.
       ELSE.
         gv_release = 'X'.
       ENDIF.
     ELSE.
       gv_release = 'X'.
     ENDIF.

**     gv_release = zssutdt025-zrelease.
**     gv_release = zssutdt025-zprint.
     IF gv_release = 'X'.
       MESSAGE e002(zz) WITH 'DCP ( ' zssutdt025-daily_call_num ' ) Batal di update'.
       gv_error = 'E'.
       RETURN.
*       LEAVE PROGRAM.
     ENDIF.
     " __* DATA: lt_026 TYPE TABLE OF zssutdt026 WITH HEADER LINE.
     SELECT * FROM zssutdt026 INTO TABLE gt_026 WHERE vkbur = zssutdt025-vkbur
                                                  AND daily_call_num = zssutdt025-daily_call_num
                                                  AND umjah = p_datum(4).
     IF sy-subrc = 0.
       SELECT * FROM kna1 INTO TABLE lt_kna1 FOR ALL ENTRIES IN gt_026 WHERE kunnr = gt_026-kunnr.
       IF sy-subrc = 0.
         SELECT * FROM knvp INTO TABLE lt_knvp FOR ALL ENTRIES IN gt_026 WHERE kunnr = gt_026-kunnr
                                                                           AND kunn2 = gt_026-kunn2
                                                                           AND parvw = 'ZS'.
       ENDIF.
       REFRESH gt_itab.
       LOOP AT gt_026.
         CLEAR gt_itab.
         MOVE-CORRESPONDING gt_026 TO gt_itab.
         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
             input  = gt_itab-kunnr
           IMPORTING
             output = gt_itab-kunnr.
         READ TABLE lt_kna1 WITH KEY kunnr = gt_026-kunnr.
         IF sy-subrc = 0.
           READ TABLE lt_knvp WITH KEY kunnr = gt_026-kunnr.
           IF sy-subrc = 0.
             gt_itab-name1 = lt_kna1-name1.
             IF lt_kna1-name2 IS NOT INITIAL.
               gt_itab-addrs = lt_kna1-name2.
             ELSE.
               gt_itab-addrs = lt_kna1-stras.
             ENDIF.

             READ TABLE gt_022 WITH KEY vkorg = p_vkorg
                                        kunnr = gt_026-kunnr
                                        vkbur = p_vkbur
                                        kunn2 = gt_026-kunn2.
             IF sy-subrc = 0.
               gt_itab-counter  = gt_022-counter.
             ENDIF.

             APPEND gt_itab.
           ENDIF.
         ENDIF.
       ENDLOOP.
*       APPEND INITIAL LINE TO gt_itab.
     ENDIF.
     SORT gt_itab BY counter.
     " __*
   ELSE.
     SORT gt_022 BY counter.

     " __* NO DATA EXIST IN DAILY CALL PLAN TABLE ZSSUTDT025 (header) / ZSSUTDT026 (detail), THEN CREATE NEW !
     " __* get default visitation matrix data
     gv_mode = 'CRT'.
     " __* filter data based on date in selection screen
     LOOP AT gt_022.
       PERFORM f_get_dayname USING p_datum '' CHANGING lv_dname.
*       PERFORM f_get_weeknumber USING p_datum CHANGING lv_week.
       PERFORM f_get_weeknumber1 USING p_datum CHANGING lv_week.
       CONCATENATE lv_dname lv_week INTO lv_fname. CONDENSE lv_fname.
       CONCATENATE 'GT_022-' lv_fname INTO lv_fname. CONDENSE lv_fname.
       ASSIGN (lv_fname) TO <fs>.
       IF <fs> = 'X'.
         lt_022 = gt_022.
         APPEND lt_022.
       ENDIF.
     ENDLOOP.
     gt_022[] = lt_022[].
     IF gt_022[] IS INITIAL.
       gv_error = 2.
       RETURN.
     ENDIF.
     " __* get master data
     SELECT * FROM kna1 INTO TABLE lt_kna1 FOR ALL ENTRIES IN gt_022 WHERE kunnr = gt_022-kunnr.
     IF sy-subrc = 0.
       SELECT * FROM knvp INTO TABLE lt_knvp FOR ALL ENTRIES IN gt_022 WHERE kunnr = gt_022-kunnr
                                                                         AND kunn2 = gt_022-kunn2
                                                                         AND parvw = 'ZS'.

     ENDIF.
     LOOP AT gt_022.
       CLEAR gt_itab.
       gt_itab-counter  = gt_022-counter.
       gt_itab-kunnr = gt_022-kunnr.
       gt_itab-kunn2 = gt_022-kunn2.
       READ TABLE lt_kna1 WITH KEY kunnr = gt_022-kunnr.
       IF sy-subrc = 0.
         READ TABLE lt_knvp WITH KEY kunnr = gt_022-kunnr.
         IF sy-subrc = 0.
           gt_itab-name1 = lt_kna1-name1.
           IF lt_kna1-name2 IS NOT INITIAL.
             gt_itab-addrs = lt_kna1-name2.
           ELSE.
             gt_itab-addrs = lt_kna1-stras.
           ENDIF.
           APPEND gt_itab.
         ENDIF.
       ENDIF.
     ENDLOOP.
     " Daily Call number di Title
     " __* create new record in Daily Call Plan Table
     DATA: lv_umjah TYPE umjah.
     lv_umjah = p_datum+0(4).
     " __* check whether Counter Table already has this data
     CLEAR zssutdt023.
     SELECT SINGLE * FROM zssutdt023 WHERE vkorg = p_vkorg AND vkbur = p_vkbur AND umjah = '9999'. "lv_umjah.
     IF sy-subrc = 0.
       " __* update daily call number in Counter Table if data already exist
       zssutdt025-daily_call_num = zssutdt023-daily_call_num + 1.
     ELSE.
       "
       zssutdt025-daily_call_num = 1.
     ENDIF.
*     APPEND INITIAL LINE TO gt_itab.
   ENDIF.

   MOVE zssutdt025-daily_call_num TO gs_header-daily_call_num.
   SHIFT gs_header-daily_call_num LEFT DELETING LEADING '0'.
 ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_MSG
*&---------------------------------------------------------------------*
 FORM f_process_msg .
   IF gv_error = 1.
     MESSAGE 'Visitation Matrix undefined' TYPE 'I'.
   ELSEIF gv_error = 2.
     MESSAGE 'No data found' TYPE 'I'.
   ENDIF.
 ENDFORM.                    " F_PROCESS_MSG

*&---------------------------------------------------------------------*
*&      Form  F_GET_DAYNAME
*&---------------------------------------------------------------------*
 FORM f_get_dayname USING date mode CHANGING weekday.
   DATA: day_p TYPE p.

   day_p = date MOD 7.
* DAY_P enthält 0 für Samstag, 1 für Sonntag, etc.. und muß
* der Kalendernotation: 1 für Montag, 2 für Dienstag, etc.,
* angepaßt werden.
   IF day_p > 1.
     day_p = day_p - 1.
   ELSE.
     day_p = day_p + 6.
   ENDIF.

   CASE day_p.
     WHEN 1.
       weekday = 'mon'.
       IF mode = 'FULL'.
         weekday = 'Senin'.
       ENDIF.
     WHEN 2.
       weekday = 'tue'.
       IF mode = 'FULL'.
         weekday = 'Selasa'.
       ENDIF.
     WHEN 3.
       weekday = 'wed'.
       IF mode = 'FULL'.
         weekday = 'Rabu'.
       ENDIF.
     WHEN 4.
       weekday = 'thu'.
       IF mode = 'FULL'.
         weekday = 'Kamis'.
       ENDIF.
     WHEN 5.
       weekday = 'fri'.
       IF mode = 'FULL'.
         weekday = 'Jumat'.
       ENDIF.
     WHEN 6.
       weekday = 'sat'.
       IF mode = 'FULL'.
         weekday = 'Sabtu'.
       ENDIF.
     WHEN 7.
       weekday = 'sun'.
       IF mode = 'FULL'.
         weekday = 'Minggu'.
       ENDIF.
   ENDCASE.
   TRANSLATE weekday TO UPPER CASE.
 ENDFORM.                    " F_GET_DAYNAME

*&---------------------------------------------------------------------*
*&      Form  F_GET_WEEKNUMBER
*&---------------------------------------------------------------------*
 FORM f_get_weeknumber  USING    p_datum
                        CHANGING p_week.
   DATA: lv_monday  TYPE sy-datum,
         lv_sunday  TYPE sy-datum.

*   DATA: lv_float TYPE p DECIMALS 1.
*   DATA: lv_int TYPE i.
*   MOVE p_datum+6(2) TO lv_float.
*   lv_float = lv_float / 7.
*   lv_int   = CEIL( lv_float ).
*   MOVE lv_int TO p_week.
   DATA: lv_week2 TYPE scal-week.
   DATA: lv_week1 TYPE scal-week.
   DATA: lv_delta_week TYPE scal-week.
   DATA: lv_date TYPE sy-datum.

   CALL FUNCTION 'GET_WEEK_INFO_BASED_ON_DATE'
    EXPORTING
      date          = p_datum
    IMPORTING
      week          = lv_week2
*      MONDAY        =
*      SUNDAY        =
             .
   CONCATENATE p_datum+0(6) '01' INTO lv_date.
   CALL FUNCTION 'GET_WEEK_INFO_BASED_ON_DATE'
     EXPORTING
       date   = lv_date
     IMPORTING
       week   = lv_week1
       monday = lv_monday
       sunday = lv_sunday.

   DATA lv_int TYPE i.
   lv_delta_week = lv_week2 - lv_week1.
   MOVE lv_delta_week TO lv_int.

   IF lv_date EQ lv_sunday.
     lv_int = lv_int.
   ELSE.
     lv_int = lv_int + 1.
   ENDIF.

   p_week = lv_int.
 ENDFORM.                    " F_GET_WEEKNUMBER

*&---------------------------------------------------------------------*
*&      Form  F_GET_WEEKNUMBER1
*&---------------------------------------------------------------------*
 FORM f_get_weeknumber1  USING    p_datum
                         CHANGING p_week.
   CALL FUNCTION 'Z_GET_WEEK_BASED_ON_DATE'
     EXPORTING
       date          = p_datum
     IMPORTING
       week          = p_week
*      LOW           =
*      HIGH          =
             .
 ENDFORM.                    " F_GET_WEEKNUMBER1

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_023
*&---------------------------------------------------------------------*
 FORM f_update_023 .
   IF gv_mode = 'CRT'.
     " __* create new record in Daily Call Plan Table
     DATA: lv_umjah TYPE umjah.
     lv_umjah = p_datum+0(4).
     " __* check whether Counter Table already has this data
     CLEAR zssutdt023.
     SELECT SINGLE * FROM zssutdt023 WHERE vkorg = p_vkorg AND vkbur = p_vkbur AND umjah = '9999'. "lv_umjah.
     IF sy-subrc = 0.
       " __* update daily call number in Counter Table if data already exist
       zssutdt023-daily_call_num = zssutdt023-daily_call_num + 1.
     ELSE.
       " __* create new record in Counter Table
       zssutdt023-vkorg = p_vkorg.
       zssutdt023-vkbur = p_vkbur.
       zssutdt023-umjah = '9999'. "lv_umjah.
       zssutdt023-daily_call_num = 1.
     ENDIF.
     MODIFY zssutdt023 FROM zssutdt023.
   ENDIF.
 ENDFORM.                    " F_UPDATE_023

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_025
*&---------------------------------------------------------------------*
 FORM f_update_025 USING fu_release.
   IF gv_mode = 'CRT'.
     CLEAR zssutdt025.
     zssutdt025-vkorg   = p_vkorg.
     zssutdt025-vkbur   = p_vkbur.
     zssutdt025-pernr   = p_pernr.
     zssutdt025-umjah   = p_datum(4). "zssutdt023-umjah.
     zssutdt025-sdate   = p_datum.
     zssutdt025-status  = 'A'.
     zssutdt025-aedat   = sy-datum.
     zssutdt025-aenam   = sy-uname.
     zssutdt025-daily_call_num  = zssutdt023-daily_call_num.
     zssutdt025-zrelease  = fu_release.
     zssutdt025-str_dcp_dat = p_datum.
     zssutdt025-end_dcp_dat = p_datum.
     MODIFY zssutdt025 FROM zssutdt025.
   ELSE.
     zssutdt025-zrelease  = fu_release.
     MODIFY zssutdt025 FROM zssutdt025.
   ENDIF.
 ENDFORM.                    " F_UPDATE_025

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_026
*&---------------------------------------------------------------------*
 FORM f_update_026 .
   " __* NOTE: SOME DATA IN DETAIL TABLE ZMSUTDT0026 WILL BE DELETED AND SOME WILL BE ADDED
   " __* DEPEND ON THE CONTENT OF TABLE CONTROL

   IF gv_mode = 'CRT'.
     " __* must be no data exist yet in Detail Table, so just insert it all
     PERFORM f_modify_data.
   ELSEIF gv_mode = 'UPD'.
     " __* Synchronize new data to existing data in Detail table.
     " __* add new data if it were not available yet in detail table
     " __* Delete data in Detail table which doesn't exist in gt_itab

     " __* first, all existing data are updated and new data are inserted
     PERFORM f_modify_data.

     " __* then delete data from database if it is not in table control (user is deleting the data)
     DATA: lt_026 TYPE TABLE OF zssutdt026.
     LOOP AT gt_026.
       READ TABLE gt_itab WITH KEY kunnr = gt_026-kunnr.
       IF sy-subrc <> 0.
         APPEND gt_026 TO lt_026.
       ENDIF.
     ENDLOOP.
     IF lt_026[] IS NOT INITIAL.
       DELETE zssutdt026 FROM TABLE lt_026.
     ENDIF.
   ENDIF.

 ENDFORM.                    " F_UPDATE_026

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DATA
*&---------------------------------------------------------------------*
 FORM f_modify_data .
   DATA: lv_dname TYPE char3,
         lv_week  TYPE char1,
         lv_fname TYPE char15.

   DATA: lt_026 TYPE TABLE OF zssutdt026.

   FIELD-SYMBOLS: <fs>.

   LOOP AT gt_itab WHERE kunnr IS NOT INITIAL.
     zssutdt026-vkbur             = zssutdt025-vkbur.
     zssutdt026-daily_call_num    = zssutdt025-daily_call_num.

     zssutdt026-kunnr             = gt_itab-kunnr.
     zssutdt026-umjah             = p_datum(4).

     zssutdt026-kunn2             = gt_itab-kunn2.
     zssutdt026-no_call_stat      = 'X'.
     zssutdt026-reason_call_id    = '00'.

     " __* is the data same as in the master visitation matrix ?
     PERFORM f_get_dayname USING p_datum '' CHANGING lv_dname.
*     PERFORM f_get_weeknumber USING p_datum CHANGING lv_week.
     PERFORM f_get_weeknumber1 USING p_datum CHANGING lv_week.
     CONCATENATE lv_dname lv_week INTO lv_fname. CONDENSE lv_fname.
     CONCATENATE 'GT_022-' lv_fname INTO lv_fname. CONDENSE lv_fname.
     ASSIGN (lv_fname) TO <fs>.
     READ TABLE gt_022 WITH KEY kunnr = gt_itab-kunnr kunn2 = gt_itab-kunn2.
     IF sy-subrc = 0.
       IF <fs> EQ 'X'.
         " yes
         zssutdt026-master_stat_indi  = 'X'.
         zssutdt026-call_date = p_datum.
       ELSE.
         " no
         CLEAR zssutdt026-master_stat_indi.
       ENDIF.
     ELSE.
       " no
       CLEAR zssutdt026-master_stat_indi.
     ENDIF.
     IF zssutdt026-call_date IS INITIAL.
       zssutdt026-call_date = p_datum.
     ENDIF.
     APPEND zssutdt026 TO lt_026.
   ENDLOOP.
   MODIFY zssutdt026 FROM TABLE lt_026.
 ENDFORM.                    " F_MODIFY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_ITAB
*&---------------------------------------------------------------------*
 FORM f_modify_itab .
   LOOP AT gt_itab.
     CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
       EXPORTING
         input  = gt_itab-kunnr
       IMPORTING
         output = gt_itab-kunnr.
     CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
       EXPORTING
         input  = gt_itab-kunn2
       IMPORTING
         output = gt_itab-kunn2.
     MODIFY gt_itab TRANSPORTING kunn2 kunnr.
   ENDLOOP.
 ENDFORM.                    " F_MODIFY_ITAB

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
 FORM f_print_form .
   DATA: lv_funame         TYPE rs38l_fnam.
   DATA: ls_ctrl_param     LIKE ssfctrlop,
         ls_output_opt     TYPE ssfcompop.
   CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
     EXPORTING
       formname           = _formname
     IMPORTING
       fm_name            = lv_funame
     EXCEPTIONS
       no_form            = 1
       no_function_module = 2
       OTHERS             = 3.
   IF sy-subrc = 0.
*    lv_output_opt-tddest    = p_dest.
*    clear: lv_output_opt-tdimmed.
*    if p_disp is initial.
*      lv_output_opt-tdimmed   = 'X'.
*    endif.
*
*    lv_output_opt-tdnewid   = 'X'.

     "f_ctrl_param-preview   = 'X'.
     "f_ctrl_param-no_dialog = 'X'.
*    gs_header-nama_toko1 = 'Apotek gadjah Mada'.
*    gs_header-kode_toko1 = '010101010101'.
*    gs_header-kode_route_list1 = '0101010101'.

     CALL FUNCTION lv_funame
       EXPORTING
         gs_header          = gs_header
*      TABLES
*        gt_detail          = gt_detail[]
         .
   ENDIF.
 ENDFORM.                    " F_PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_DATA
*&---------------------------------------------------------------------*
 FORM f_populate_data .
   DATA: lv_tabix TYPE i,
         lv_ctabi TYPE char2,
         lv_fname TYPE char30.
   FIELD-SYMBOLS <fs>.
   LOOP AT gt_itab.
     lv_tabix = sy-tabix.
     MOVE lv_tabix TO lv_ctabi. CONDENSE lv_ctabi.
     CONCATENATE 'GS_HEADER-NAMA_TOKO' lv_ctabi INTO lv_fname. CONDENSE lv_fname.
     ASSIGN (lv_fname) TO <fs>.
     <fs> = gt_itab-name1.
     CONCATENATE 'GS_HEADER-KODE_TOKO' lv_ctabi INTO lv_fname. CONDENSE lv_fname.
     ASSIGN (lv_fname) TO <fs>.
     <fs> = gt_itab-kunnr.
     CONCATENATE 'GS_HEADER-KODE_ROUTE_LIST' lv_ctabi INTO lv_fname. CONDENSE lv_fname.
     ASSIGN (lv_fname) TO <fs>.
     <fs> = gt_itab-kunn2.
   ENDLOOP.
   gs_header-total_call = lv_ctabi.
   CONCATENATE p_vkbur '-' p_datum+0(4) '-' zssutdt025-daily_call_num INTO gs_header-kode_dok.
   MOVE p_vkorg TO gs_header-vkorg.
 ENDFORM.                    " F_POPULATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_CHANGES
*&---------------------------------------------------------------------*
 FORM f_check_changes .
   DATA: lv_c1(1) TYPE c, lv_c2(1) TYPE c.
   CLEAR lv_c1. CLEAR lv_c2. CLEAR gv_changes.
   " __* check table against itab
   LOOP AT gt_026.
     READ TABLE gt_itab WITH KEY kunnr = gt_026-kunnr.
     IF sy-subrc <> 0.
       lv_c1 = 'X'.
       EXIT.
     ENDIF.
   ENDLOOP.
   " __* check itab against table
   LOOP AT gt_itab.
     READ TABLE gt_026 WITH KEY kunnr = gt_itab-kunnr.
     IF sy-subrc <> 0.
       lv_c2 = 'X'.
       EXIT.
     ENDIF.
   ENDLOOP.
   IF lv_c1 = 'X' OR lv_c2 = 'X'.
     gv_changes = 'X'.
   ENDIF.

   IF gv_subrc IS NOT INITIAL.
     CLEAR gv_changes.
   ENDIF.
 ENDFORM.                    " F_CHECK_CHANGES

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATABASE
*&---------------------------------------------------------------------*
 FORM f_save_database .
****   DATA lv_answer TYPE char1.
****
*****   if gv_error_validation is initial.
****   CLEAR lv_answer.
****
****   CALL FUNCTION 'POPUP_TO_CONFIRM'
****     EXPORTING
****       text_question         = 'Do you want to release?'
****       text_button_1         = 'Yes'
****       text_button_2         = 'No'
****       display_cancel_button = 'X'
****     IMPORTING
****       answer                = lv_answer
****     EXCEPTIONS
****       text_not_found        = 1
****       OTHERS                = 2.
****
****   CASE lv_answer.
****     WHEN '1'.
   PERFORM f_modify_itab.
   PERFORM f_update_023. "counter (daily call number)
   PERFORM f_update_025 USING 'X'. "header
   PERFORM f_update_026. "detail
   MESSAGE 'Records have been saved' TYPE 'S'.
   REFRESH gt_026.
   SELECT * FROM zssutdt026 INTO TABLE gt_026 WHERE vkbur = zssutdt025-vkbur
                                                AND daily_call_num = zssutdt025-daily_call_num.
***     WHEN '2'.
***       PERFORM f_modify_itab.
***       PERFORM f_update_023. "counter (daily call number)
***       PERFORM f_update_025 USING ''. "header
***       PERFORM f_update_026. "detail
***       MESSAGE 'Records have been saved' TYPE 'S'.
***       REFRESH gt_026.
***       SELECT * FROM zssutdt026 INTO TABLE gt_026 WHERE vkbur = zssutdt025-vkbur
***                                                    AND daily_call_num = zssutdt025-daily_call_num.
***     WHEN OTHERS.
***   ENDCASE.
*   endif.
 ENDFORM.                    " F_SAVE_DATABASE

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
 FORM f_validate_screen_1000 .
   IF p_vkbur IS NOT INITIAL.
     AUTHORITY-CHECK OBJECT  'V_VBKA_VKO'
             ID 'VKBUR' FIELD p_vkbur
             ID 'ACTVT' FIELD '01'.
     IF sy-subrc NE 0.
       MESSAGE e000(zab) WITH
       'You have no authorization for Sales Office' p_vkbur.
     ENDIF.
   ENDIF.
   IF p_chg = 'X' OR p_del = 'X'. " OR p_dsp = 'X'.
     IF s_dcp-low IS INITIAL.
       PERFORM f_screen_error USING 'BB1'.
     ENDIF.
   ENDIF.
   IF p_dsp = 'X'.
**     IF s_pernr-low IS INITIAL.
**       PERFORM f_screen_error USING 'DSP'.
**     ENDIF.
     IF s_datum IS INITIAL.
       PERFORM f_screen_error USING 'DTB'.
     ENDIF.
   ENDIF.
   IF p_crt = 'X' OR p_chg = 'X' OR p_del = 'X'.
     IF p_datum IS INITIAL.
       PERFORM f_screen_error USING 'DTA'.
     ENDIF.
     IF p_kunn2 IS INITIAL.
       PERFORM f_screen_error USING 'CRT'.
     ENDIF.
     IF p_pernr IS INITIAL.
       PERFORM f_screen_error USING 'CRT'.
     ENDIF.
   ENDIF.
   IF p_dsp NE 'X'.
     IF p_datum IS NOT INITIAL.
       IF p_crt EQ 'X'.
         IF p_datum < sy-datum.
           MESSAGE e002(zz) WITH 'Mohon diperhatikan input tanggalnya !!!'.
         ENDIF.
       ENDIF.
       "IF p_pernr IS NOT INITIAL.
       IF p_crt NE 'X'.
         IF p_chg = 'X'.
           SELECT SINGLE pernr INTO p_pernr FROM zssutdt025
                 WHERE vkorg = p_vkorg AND
                       vkbur = p_vkbur AND
                       status NE 'D' AND
                       pernr = p_pernr AND
                       umjah = p_datum(4) AND
                       daily_call_num eq s_dcp-low AND
                       "daily_call_num = p_dcp AND
                       str_dcp_dat = p_datum. "  AND
           "zrelease = 'X'. " AND zprint NE 'X'.
         ENDIF.
         IF p_del = 'X'.
           SELECT SINGLE * FROM zssutdt025
                 WHERE vkorg = p_vkorg AND
                       vkbur = p_vkbur AND
                       status NE 'D' AND
                       pernr = p_pernr AND
                       "umjah = p_datum(4) AND
                       daily_call_num IN s_dcp AND
                       "daily_call_num = p_dcp1 AND
                       str_dcp_dat = p_datum. "  AND
           "zrelease = 'X'. " AND zprint NE 'X'.
         ENDIF.
         IF sy-subrc NE 0.
           WRITE zssutdt025-end_dcp_dat TO gv_text.
           CONCATENATE 'DCP No ' s_dcp-low 'Tidak ditemukan' INTO gv_message SEPARATED BY space.
           MESSAGE e002(zz) WITH gv_message.
         ELSE.
****           IF zssutdt025-zprint  = 'X'.
****             CONCATENATE 'DCP No ' s_dcp-low 'Sudah Cetak atau dikirim ke SFA' INTO gv_message SEPARATED BY space.
****             MESSAGE e002(zz) WITH gv_message.
****           ENDIF.
         ENDIF.
       ELSE.
         SELECT SINGLE * FROM zssutdt025
               WHERE vkorg = p_vkorg AND
                     vkbur = p_vkbur AND
                     pernr = p_pernr AND
                     umjah = p_datum(4) AND
                     ( str_dcp_dat >= p_datum OR end_dcp_dat >= p_datum ) AND
                     zrelease = 'X' AND
                     status NE 'D'.
         IF sy-subrc EQ 0.
           WRITE zssutdt025-end_dcp_dat TO gv_text.
           CONCATENATE 'DCP sebelumnya tanggal'  gv_text INTO gv_message SEPARATED BY space.
           MESSAGE e002(zz) WITH gv_message.
         ENDIF.
       ENDIF.
       "ENDIF.
     ENDIF.
   ENDIF.
 ENDFORM.                    " F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM f_modify_screen_1000 .
   LOOP AT SCREEN.
     CASE screen-group1.
       WHEN 'BB1'.
         CASE 'X'.
           WHEN  p_del OR p_chg.
             screen-active = '1'.
             IF screen-name = 'S_DCP-HIGH' OR screen-name = '%_S_DCP_%_APP_%-VALU_PUSH'.
               screen-invisible = 1.
               screen-active = 0.
             ENDIF.
             MODIFY SCREEN.
           WHEN p_dsp.
             screen-active = '1'.
             IF screen-name = 'S_DCP-HIGH'.
               screen-invisible = 0.
               screen-active = 1.
             ENDIF.
             MODIFY SCREEN.
           WHEN  p_crt.
             screen-active = '0'.
             MODIFY SCREEN.


         ENDCASE.
       WHEN 'CRT'.
         CASE 'X'.
           WHEN p_crt OR p_del OR p_chg.
             screen-active = '1'.
             MODIFY SCREEN.
           WHEN OTHERS.
             screen-active = '0'.
             MODIFY SCREEN.

         ENDCASE.
       WHEN 'DSP'.
         CASE 'X'.
           WHEN p_dsp.
             screen-active = '1'.
             MODIFY SCREEN.
           WHEN OTHERS.
             screen-active = '0'.
             MODIFY SCREEN.

         ENDCASE.
       WHEN 'DTB'.
         CASE 'X'.
           WHEN p_dsp.
             screen-active = '1'.
             MODIFY SCREEN.
           WHEN OTHERS.
             screen-active = '0'.
             MODIFY SCREEN.

         ENDCASE.
       WHEN 'DTA'.
         CASE 'X'.
           WHEN p_dsp.
             screen-active = '0'.
             MODIFY SCREEN.
           WHEN OTHERS.
             screen-active = '1'.
             MODIFY SCREEN.
         ENDCASE.

     ENDCASE.
   ENDLOOP.
 ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_SCREEN_ERROR
*&---------------------------------------------------------------------*
 FORM f_screen_error  USING    fu_group.
   DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

   LOOP AT SCREEN.
     IF screen-group1 = fu_group.
       screen-input  = 1.
     ELSE.
       screen-input  = 0.
     ENDIF.
     MODIFY SCREEN.
   ENDLOOP.
   MESSAGE e000(zab) WITH lv_mess.
 ENDFORM.                    " F_SCREEN_ERROR




*---------------------------------------------------------------------*
*       FORM f_alv                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_DATA                                                       *
*---------------------------------------------------------------------*
 FORM f_alv TABLES ft_report.
   PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
   PERFORM f_clear_alv_data.
   PERFORM f_build_fieldcat    TABLES  ft_report.
   PERFORM f_build_layout      USING   d_layout.
   PERFORM f_build_sortfield   USING   t_alv_isort[].
   PERFORM f_build_event       TABLES  t_alv_event[].
   PERFORM f_build_event_exit.
   PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

   CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
     EXPORTING
       i_callback_program       = d_repid
       i_callback_pf_status_set = 'F_SET_PF_STATUS'
       i_callback_user_command  = 'F_USER_COMMAND'
       is_layout                = d_layout
       it_fieldcat              = t_alv_fieldcat[]
       it_sort                  = t_alv_isort[]
       i_default                = 'X'
       i_save                   = 'A'
       is_variant               = d_alv_variant
       it_events                = t_alv_event[]
       it_event_exit            = t_event_exit[]
       is_print                 = d_print
     TABLES
       t_outtab                 = ft_report
     EXCEPTIONS
       program_error            = 1
       OTHERS                   = 2.
 ENDFORM.                    "f_alv

*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 FORM f_build_fieldcat TABLES ft_report.
   REFRESH: t_alv_fieldcat.

****VKORG VKORG CHAR  4 0 Sales Organization
****VKBUR VKBUR CHAR  4 0 Sales Office
****PERNR PERNR_D NUMC  8 0 Personnel Number
****UMJAH UMJAH NUMC  4 0 Year For Which Sales are Given
****SDATE SDATE DATS  8 0 Start Date
****STATUS  CHAR1 CHAR  1 0 Single-Character Indicator
****AEDAT AEDAT DATS  8 0 Changed On
****AENAM AENAM CHAR  12  0 Name of Person Who Changed Object
****DAILY_CALL_NUM  NUM6  NUMC  6 0 Numerical Character Field of Length 6
****ZRELEASE  CHAR1 CHAR  1 0 Single-Character Indicator
****ZPRINT  CHAR1 CHAR  1 0 Single-Character Indicator
****STR_DCP_DAT ZSTR_DCP  DATS  8 0 Start DCP Date
****END_DCP_DAT ZEND_DCP  DATS  8 0 End DCP Date

   PERFORM f_fieldcatg USING ft_report:
     'VKORG'          'ZSSUTDT025' 'VKORG'          '' '' ''               '' '' '' '' '' '' '' '',
     'VKBUR'          'ZSSUTDT025' 'VKBUR'          '' '' ''               '' '' '' '' '' '' '' '',
     'PERNR'          'ZSSUTDT025' 'PERNR'          '' '' 'Sales Id'   '' '' '' '' '' '' '' '',
     'ENAME'          'PA0001'     'ENAME'          '' '' 'Salesman Name'   '' '' '' '' '' '' '' '',
     'UMJAH'          'ZSSUTDT025' 'UMJAH'          '' '' 'DCP Year'       '' '' '' '' '' '' '' '',
     'SDATE'          'ZSSUTDT025' 'SDATE'          '' '' 'DCP Date'       '' '' '' '' '' '' '' '',
     'DAILY_CALL_NUM' 'ZSSUTDT025' 'DAILY_CALL_NUM' '' '' 'DCP No.'        '' '' '' '' '' '' '' '',
"     'ZRELEASE'       'ZSSUTDT025' 'ZRELEASE'       '' '' 'Release'        '' '' '' '' '' '' '' '',
     'ZPRINT'         'ZSSUTDT025' 'ZPRINT'         '' '' 'TiMOS'            '' '' '' '' '' '' '' '',
     'STR_DCP_DAT'    'ZSSUTDT025' 'STR_DCP_DAT'    '' '' 'Start DCP'      '' '' '' '' '' '' '' '',
     'END_DCP_DAT'    'ZSSUTDT025' 'END_DCP_DAT'    '' '' 'End DCP'        '' '' '' '' '' '' '' '',
     'BBELN'          'ZFBIH_SFA'  'BBELN'          '' '' 'BI No.'         '' '' '' '' '' '' '' ''.
 ENDFORM.                    " F_FIELDCAT

*---------------------------------------------------------------------*
*       FORM f_fieldcats                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_FNAME                                                      *
*  -->  FU_OUTLEN                                                     *
*  -->  FU_NOSIGN                                                     *
*  -->  FU_NOOUT                                                      *
*  -->  FU_TEXT                                                       *
*  -->  FU_REFTB                                                      *
*  -->  FU_REFFNAME                                                   *
*  -->  FU_DECIMALS                                                   *
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM f_fieldcatg USING    value(fu_types)
                           value(fu_fname)
                           value(fu_reftb)
                           value(fu_refld)
                           value(fu_noout)
                           value(fu_outln)
                           value(fu_fltxt)
                           value(fu_dosum)

                           value(fu_hotsp)
                           value(fu_dec)
                           value(fu_waers)
                           value(fu_meins)
                           value(fu_waers_f)
                           value(fu_meins_f)
                           value(fu_checkbox).

   DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.

   CLEAR: ld_fieldcat.
   ld_fieldcat-tabname           = fu_types.
   ld_fieldcat-fieldname         = fu_fname.
   ld_fieldcat-ref_tabname       = fu_reftb.
   ld_fieldcat-ref_fieldname     = fu_refld.
   ld_fieldcat-no_out            = fu_noout.
   ld_fieldcat-outputlen         = fu_outln.
   ld_fieldcat-seltext_l         = fu_fltxt.
   ld_fieldcat-seltext_m         = fu_fltxt.
   ld_fieldcat-seltext_s         = fu_fltxt.
   ld_fieldcat-reptext_ddic      = fu_fltxt.
   ld_fieldcat-no_out            = fu_noout.
   ld_fieldcat-do_sum            = fu_dosum.
   ld_fieldcat-hotspot           = fu_hotsp.
   ld_fieldcat-decimals_out      = fu_dec.
   ld_fieldcat-currency          = fu_waers.
   ld_fieldcat-quantity          = fu_meins.
   ld_fieldcat-qfieldname        = fu_meins_f.
   ld_fieldcat-cfieldname        = fu_waers_f.
   ld_fieldcat-checkbox          = fu_checkbox.
   APPEND ld_fieldcat TO t_alv_fieldcat.
   CLEAR ld_fieldcat.
 ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM f_build_event                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_EVENTS                                                     *
*---------------------------------------------------------------------*
 FORM f_build_event TABLES ft_events LIKE t_events.
   REFRESH: ft_events.
   CLEAR ft_events.
   ft_events-name = slis_ev_top_of_page.
   ft_events-form = 'F_TOP_OF_PAGE'.
   APPEND ft_events.
 ENDFORM.                    "f_build_event

*---------------------------------------------------------------------*
*       FORM f_build_event_exit                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 FORM f_build_event_exit.
   CLEAR t_event_exit.
   t_event_exit-ucomm = '&OUP'.
   t_event_exit-after = 'X'.
   APPEND t_event_exit.

   CLEAR t_event_exit.
   t_event_exit-ucomm = '&ODN'.
   t_event_exit-after = 'X'.
   APPEND t_event_exit.
 ENDFORM.                    "f_build_event_exit

*---------------------------------------------------------------------*
*       FORM f_build_layout                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
 FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
   fu_layout-zebra              = 'X'.
   fu_layout-colwidth_optimize  = space.
   fu_layout-no_colhead         = space.
   fu_layout-group_change_edit  = 'X'.
   fu_layout-detail_popup       = 'X'.
   "fu_layout-box_fieldname      = 'CHECK'.
 ENDFORM.                    "f_build_layout

*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_PRINT                                                      *
*---------------------------------------------------------------------*
 FORM f_build_print USING fu_print TYPE slis_print_alv.
   fu_print-no_print_listinfos    = 'X'.
   fu_print-no_print_selinfos     = 'X'.
   fu_print-no_coverpage          = 'X'.
   fu_print-no_print_hierseq_item = 'X'.
 ENDFORM.                    "f_build_print

*---------------------------------------------------------------------*
*       FORM f_build_sortfield                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_SORT                                                       *
*---------------------------------------------------------------------*
 FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
   DATA: ld_sort TYPE slis_sortinfo_alv.

   CLEAR ld_sort.
   ld_sort-fieldname = 'PERNR'.
   ld_sort-up        = 'X'.
   APPEND ld_sort TO fu_sort.

   CLEAR ld_sort.
   ld_sort-fieldname = 'DAILY_CALL_NUM'.
   ld_sort-up        = 'X'.
   APPEND ld_sort TO fu_sort.

 ENDFORM.                    "f_build_sortfield

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 FORM f_top_of_page.
   PERFORM f_hdr_uline.
   PERFORM f_hdr_line1 USING sy-title.
   PERFORM f_hdr_line2 USING ''.
   PERFORM f_hdr_line3 USING ''.
   PERFORM f_hdr_uline.
 ENDFORM.                    "f_top_of_page

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM f_free_memory.
* here free all the internal table used in the program.
***  REFRESH: t_out.
***  CLEAR: t_out.
 ENDFORM.                    " F_FREE_MEMORY
*&---------------------------------------------------------------------*
*&      Form  f_clear_alv_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM f_clear_alv_data.
   CLEAR:t_alv_fieldcat,
         t_alv_event,
         t_events,
         t_alv_isort,
         t_alv_filter,
         t_event_exit,
         d_alv_isort,
         d_alv_variant,
         d_alv_list_scroll,
         d_alv_sort_postn,
         d_alv_keyinfo,
         d_alv_fieldcat,
         d_alv_formname,
         d_alv_ucomm,
         d_alv_print,
         d_alv_repid,
         d_alv_tabix,
         d_alv_subrc,
         d_alv_screen_start_column,
         d_alv_screen_start_line,
         d_alv_screen_end_column,
         d_alv_screen_end_line,
         d_alv_layout,
         d_layout,
         d_repid,
         d_print.

   REFRESH: t_alv_fieldcat,
            t_alv_event,
            t_events,
            t_alv_isort,
            t_alv_filter,
            t_event_exit.

   d_repid = sy-repid.
 ENDFORM.                    " f_clear_alv_data

*---------------------------------------------------------------------*
*       FORM f_set_pf_status                                          *
*---------------------------------------------------------------------*
 FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
   sy-lsind = 0.
   SET PF-STATUS 'DISPLAY'.

***  IF t_out[] IS INITIAL.
***    SET PF-STATUS 'STANDARD'.
***  ELSE.
***    SET PF-STATUS 'TOEXEC'.
***  ENDIF.
 ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM f_gui_message                                            *
*---------------------------------------------------------------------*
 FORM f_gui_message USING fu_text1 fu_text2.
   DATA: ld_text1(100)    TYPE c.

   CONCATENATE fu_text1 fu_text2 INTO ld_text1
               SEPARATED BY space.
   CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
     EXPORTING
       percentage = 0
       text       = ld_text1.
 ENDFORM.                    "f_gui_message

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM f_alv_variant_exist USING     fu_vari
                          CHANGING  fc_alv_variant STRUCTURE disvariant.
   IF NOT fu_vari IS INITIAL.
     MOVE fu_vari TO fc_alv_variant-variant.
     fc_alv_variant-report = d_repid.
     CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
       EXPORTING
         i_save        = 'A'
       CHANGING
         cs_variant    = fc_alv_variant
       EXCEPTIONS
         wrong_input   = 1
         not_found     = 2
         program_error = 3
         OTHERS        = 4.
     IF sy-subrc <> 0.
       IF NOT sy-msgid IS INITIAL.
         MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
       ENDIF.
     ENDIF.
   ELSE.
     CLEAR fc_alv_variant.
     fc_alv_variant-report = sy-repid.
   ENDIF.
 ENDFORM.                    " F_ALV_VARIANT_EXIST

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
 FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
   DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

 ENDFORM.                    "f_user_command
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM f_get_data_display .
   DATA: li_zssutdt025 TYPE zssutdt025 OCCURS 0.
   REFRESH: gt_out.
   SELECT  * INTO TABLE gt_zssutdt025 FROM zssutdt025
      WHERE vkorg = p_vkorg AND
            vkbur = p_vkbur AND
            pernr IN  s_pernr AND
            umjah = s_datum-low(4) AND
            sdate IN s_datum AND
            daily_call_num IN  s_dcp.
   IF sy-subrc EQ 0.
     li_zssutdt025[] = gt_zssutdt025[].
     SORT li_zssutdt025 BY pernr.
     DELETE ADJACENT DUPLICATES FROM li_zssutdt025 COMPARING pernr.
     IF li_zssutdt025[] IS NOT INITIAL.
       SELECT * INTO CORRESPONDING FIELDS OF TABLE i_p0001 FROM pa0001
         FOR ALL ENTRIES IN li_zssutdt025
         WHERE pernr = li_zssutdt025-pernr.
     ENDIF.
     li_zssutdt025[] = gt_zssutdt025[].
     SORT li_zssutdt025 BY daily_call_num.
     DELETE ADJACENT DUPLICATES FROM li_zssutdt025 COMPARING daily_call_num.
     SORT li_zssutdt025 BY vkorg vkbur daily_call_num.
     IF li_zssutdt025[] IS NOT INITIAL.
       SELECT * INTO CORRESPONDING FIELDS OF TABLE i_bih FROM zfbih_sfa
         FOR ALL ENTRIES IN li_zssutdt025
         WHERE bukrs = li_zssutdt025-vkorg AND
               vkbur = li_zssutdt025-vkbur AND
               daily_call_num =  li_zssutdt025-daily_call_num.
     ENDIF.
     LOOP AT gt_zssutdt025 INTO wa_zssutdt025.
       CLEAR: gt_out, wa_p0001, wa_bih.
       MOVE-CORRESPONDING wa_zssutdt025 TO gt_out.
       SORT i_p0001 BY pernr.
       READ TABLE i_p0001 INTO wa_p0001 WITH KEY pernr = wa_zssutdt025-pernr
       BINARY SEARCH.
       IF sy-subrc EQ 0.
         gt_out-ename = wa_p0001-ename.
       ENDIF.
       SORT i_bih BY bukrs vkbur daily_call_num.
       READ TABLE i_bih INTO wa_bih WITH KEY bukrs =  wa_zssutdt025-vkorg
                                             vkbur =  wa_zssutdt025-vkbur
                                             daily_call_num =  wa_zssutdt025-daily_call_num
       BINARY SEARCH.
       IF sy-subrc EQ 0.
         gt_out-bbeln = wa_bih-bbeln.
       ENDIF.
       APPEND gt_out.
     ENDLOOP.
   ENDIF.

 ENDFORM.                    " F_GET_DATA_DISPLAY
