*&---------------------------------------------------------------------*
*&  Include           ZSSUT_R006_F01
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
       PERFORM fcode_insert_row USING    p_tc_name
                                         p_table_name.
       CLEAR p_ok.

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
   DATA lv_tabix LIKE sy-tabix.
   REFRESH gt_data.
   SELECT * FROM zssutdt025 INTO TABLE gt_025 WHERE vkorg = p_vkorg AND vkbur = p_vkbur AND sdate IN s_date AND pernr IN s_vrtnr.
   IF sy-subrc = 0.
     SELECT * FROM zssutdt026 INTO TABLE gt_026 FOR ALL ENTRIES IN gt_025 WHERE vkbur = gt_025-vkbur
                                                                            AND daily_call_num = gt_025-daily_call_num
                                                                            AND umjah = gt_025-umjah.
     IF sy-subrc = 0.
       LOOP AT gt_026.
         MOVE-CORRESPONDING gt_026 TO gt_data.
         READ TABLE gt_025 WITH KEY daily_call_num = gt_026-daily_call_num.
         IF sy-subrc = 0.
           gt_data-vrtnr = gt_025-pernr.
           gt_data-vkorg = gt_025-vkorg.
           gt_data-vkbur = gt_025-vkbur.
           gt_data-sdate = gt_025-sdate.
           APPEND gt_data.
         ENDIF.
       ENDLOOP.
       DATA lt_data LIKE TABLE OF gt_data WITH HEADER LINE.
       DATA lt_0002 TYPE TABLE OF pa0002 WITH HEADER LINE.
       DATA lt_0001 TYPE TABLE OF pa0001 WITH HEADER LINE.
       DATA lt_wdes TYPE TABLE OF t542t WITH HEADER LINE.

       lt_data[] = gt_data[].
       SORT lt_data BY vrtnr.
       DELETE ADJACENT DUPLICATES FROM lt_data COMPARING vrtnr.
       " complete name
       SELECT * FROM pa0002 INTO TABLE lt_0002 FOR ALL ENTRIES IN lt_data WHERE pernr = lt_data-vrtnr AND endda = '99991231'.
       " work type
       SELECT * FROM pa0001 INTO TABLE lt_0001 FOR ALL ENTRIES IN lt_data WHERE pernr = lt_data-vrtnr AND endda = '99991231'.
       " description of work type
       SELECT * FROM t542t INTO TABLE lt_wdes FOR ALL ENTRIES IN lt_0001 WHERE ansvh = lt_0001-ansvh AND spras = 'E' AND molga = '34'.
       " working days ...
       DATA lt_dats TYPE TABLE OF rke_dat WITH HEADER LINE.
       CALL FUNCTION 'RKE_SELECT_FACTDAYS_FOR_PERIOD'
         EXPORTING
           i_datab               = s_date-low
           i_datbi               = s_date-high
           i_factid              = 'T0'
         TABLES
           eth_dats              = lt_dats[]
         EXCEPTIONS
           date_conversion_error = 1
           OTHERS                = 2.
       DATA lv_num_date TYPE i.
       DESCRIBE TABLE lt_dats LINES lv_num_date.

       LOOP AT gt_data.
         MOVE-CORRESPONDING gt_data TO gt_itab.
         READ TABLE lt_0002 WITH KEY pernr = gt_data-vrtnr.
         IF sy-subrc = 0.
           gt_itab-cname = lt_0002-cname.
         ENDIF.
         READ TABLE lt_0001 WITH KEY pernr = gt_data-vrtnr.
         IF sy-subrc = 0.
           gt_itab-ansvh = lt_0001-ansvh.
         ENDIF.
         READ TABLE lt_wdes WITH KEY ansvh = gt_itab-ansvh.
         IF sy-subrc = 0.
           gt_itab-atx = lt_wdes-atx.
         ENDIF.
         gt_itab-jml_kerja = lv_num_date.
         APPEND gt_itab.
       ENDLOOP.

       DATA lt_itab LIKE TABLE OF gt_itab WITH HEADER LINE.
       lt_itab[] = gt_itab[].
       SORT gt_itab BY vrtnr kunn2.
       " __* UNIQUE PER PERNR & ROUTE LIST
       DELETE ADJACENT DUPLICATES FROM gt_itab COMPARING vrtnr." kunn2.
       LOOP AT gt_itab.
         MOVE sy-tabix TO lv_tabix.
         CLEAR: gt_itab-jml_bil, gt_itab-jml_eff_call, gt_itab-jml_unvisit, gt_itab-jml_no_call.
         LOOP AT gt_data WHERE vrtnr = gt_itab-vrtnr. " AND kunn2 = gt_itab-kunn2.
           IF gt_data-bistat_indi EQ space.
             gt_itab-jml_no_call = gt_itab-jml_no_call + 1.
           ELSE.
             gt_itab-call_up = gt_itab-call_up + 1.
           ENDIF.
           IF gt_data-vbeln IS NOT INITIAL.
             gt_itab-jml_bil = gt_itab-jml_bil + 1.
             IF gt_data-bistat_indi EQ space.
               gt_itab-w_order = gt_itab-w_order + 1.
             ENDIF.
           ELSE.
             IF gt_data-reason_call_id = '00'.
               gt_itab-jml_unvisit = gt_itab-jml_unvisit + 1.
             ELSE.
               gt_itab-wo_order = gt_itab-wo_order + 1.
             ENDIF.
           ENDIF.
           gt_itab-act_call_up = gt_itab-w_order + gt_itab-wo_order + gt_itab-call_up.
         ENDLOOP.
         gt_itab-jml_kerja = lv_num_date.
         IF gt_itab-jml_kerja > 0.
           gt_itab-jml_eff_call = gt_itab-jml_bil / gt_itab-jml_kerja.
         ENDIF.
         MODIFY gt_itab INDEX lv_tabix.
       ENDLOOP.
     ENDIF.
   ENDIF.
 ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_DATA
*&---------------------------------------------------------------------*
 FORM f_display_data .
   IF gt_itab[] IS NOT INITIAL.
     CALL SCREEN 0100.
   ELSE.
     MESSAGE 'Data not found' TYPE 'I'.
   ENDIF.
 ENDFORM.                    " F_DISPLAY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ALV
*&---------------------------------------------------------------------*
 FORM f_display_alv .
   DATA: lv_date TYPE char10.
   CONCATENATE sy-datum+6(2) '.' sy-datum+4(2) '.' sy-datum+0(4) INTO lv_date.

   PERFORM f_alv_init.

   CLEAR x_alv_layout.
   x_alv_layout-zebra              = 'X'.
   x_alv_layout-group_change_edit  = 'X'.
   x_alv_layout-f2code             = '&IC1'.
   x_alv_layout-def_status         = 'X'.

   PERFORM f_build_header USING: "'H' '' 'Report of Daily Call Realization',
                                 'S' 'Date: ' lv_date,
                                 'S' 'User: ' sy-uname.

   PERFORM f_alv_build_event USING: slis_ev_top_of_page 'F_TOP_OF_PAGE_ALV'.

   PERFORM f_alv_build_catalog USING 'GT_ITAB' :
         'VRTNR' 'Sales Emp.' '' '' '10' 'C' '' '',
         'CNAME' 'Sales Emp.Name' '' '' '30' 'C' '' '',
         'ANSVH' 'Sales Emp.Type' '' '' '3' 'C' '' '',
         'ATX' 'Sales Emp.Desc' '' '' '15' 'C' '' '',
         'KUNN2' 'Route List' '' '' '10' 'C' '' '',
         'JML_NO_CALL' 'Plan Call' '' '' '10' 'R' '' '',
         'ACT_CALL_UP' 'Act Call' '' '' '11' 'R' '' '',
         'W_ORDER' 'Call P w.Order' '' '' '14' 'R' '' '',
         'WO_ORDER' 'Call P w/o Order' '' '' '16' 'R' '' '',
         'JML_UNVISIT' 'Unvisit' '' '' '10' 'R' '' '',
         'CALL_UP' 'Call Up' '' '' '10' 'R' '' '',
         'JML_BIL' 'Strike' '' '' '10' 'R' '' '',
         'JML_KERJA' 'Hari Kerja' '' '' '10' 'R' '' '',
         'JML_EFF_CALL' 'Avg.Strike/Day' '' '' '14' 'R' '' ''.

   d_alv_stats = 'F_ALV_STATUS'.

   PERFORM f_alv_grid_display TABLES gt_itab[].

 ENDFORM.                    " F_DISPLAY_ALV

*&---------------------------------------------------------------------*
*&      Form  F_ALV_STATUS
*&---------------------------------------------------------------------*
 FORM f_alv_status USING fu_extab TYPE slis_t_extab.        "#EC CALLED
   REFRESH fu_extab.
   SET PF-STATUS 'STANDARD' EXCLUDING fu_extab.
 ENDFORM. "f_alv_status

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_HEADER
*&---------------------------------------------------------------------*
 FORM f_build_header  USING    p_typ p_key p_info.
   DATA: ls_alv_header LIKE LINE OF gt_alv_header.
   CLEAR ls_alv_header.
   ls_alv_header-typ = p_typ.
   ls_alv_header-key = p_key.
   ls_alv_header-info = p_info.
   APPEND ls_alv_header TO gt_alv_header.
 ENDFORM.                    " F_BUILD_HEADER
