*----------------------------------------------------------------------*
*   INCLUDE ZPM_BREAKDOWNF01                                           *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_data.
  CASE 'X'.
    WHEN radio3.
      CONCATENATE pa_gjahr so_monat-high '01' INTO va_datum.
      CONCATENATE pa_gjahr so_monat-low '01' INTO ra_ausbs-low.
      CONCATENATE pa_gjahr so_monat-high '01' INTO ra_ausbs-high.
      CALL FUNCTION 'LAST_DAY_OF_MONTHS'
        EXPORTING
          day_in            = ra_ausbs-high
        IMPORTING
          last_day_of_month = ra_ausbs-high.
      ra_ausbs-sign    = 'I'.
      ra_ausbs-option  = 'BT'.
      APPEND ra_ausbs.

      va_times = ( so_monat-high - so_monat-low ) + 1.

    WHEN OTHERS.
      CONCATENATE pa_gjahr so_monat-high '01' INTO va_datum.
      CONCATENATE pa_gjahr so_monat-low '01' INTO ra_ausbs-low.
      CONCATENATE pa_gjahr so_monat-high '01' INTO ra_ausbs-high.
      CALL FUNCTION 'LAST_DAY_OF_MONTHS'
        EXPORTING
          day_in            = ra_ausbs-high
        IMPORTING
          last_day_of_month = ra_ausbs-high.
      ra_ausbs-sign    = 'I'.
      ra_ausbs-option  = 'BT'.
      APPEND ra_ausbs.
  ENDCASE.

  CLEAR: ra_ausbs-high.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = va_datum
    IMPORTING
      last_day_of_month = va_datum.

  ra_ausbs-low     = '00000000'.
  ra_ausbs-sign    = 'I'.
  ra_ausbs-option  = 'EQ'.
  APPEND ra_ausbs.

  ra_ausbs-low     = va_datum.
  ra_ausbs-sign    = 'I'.
  ra_ausbs-option  = 'GT'.
  APPEND ra_ausbs.
ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  CASE 'X'.
    WHEN radio1 OR radio3.
      SELECT qmnum iwerk tplnr equnr strmn ausbs strur auztb auszt
             maueh msaus aufnr qmtxt
        FROM viqmel
        INTO CORRESPONDING FIELDS OF TABLE t_viqmel
        WHERE qmart EQ 'M1' AND
              ausbs IN ra_ausbs AND
              iwerk EQ pa_iwerk AND
              strmn LE va_datum AND
              tplnr IN so_tplnr AND
              msaus EQ 'X'.

    WHEN radio2.
      SELECT qmnum iwerk tplnr equnr strmn ausbs strur auztb auszt
             maueh msaus aufnr qmtxt
        FROM viqmel
        INTO CORRESPONDING FIELDS OF TABLE t_viqmel
        WHERE qmart EQ 'M1' AND
              ausbs IN ra_ausbs AND
              iwerk EQ pa_iwerk AND
              strmn LE va_datum AND
              tplnr IN so_tplnr AND
              msaus EQ space.
  ENDCASE.

  IF t_viqmel[] IS NOT INITIAL.
    SELECT aufnr a~aufpl aplzl ltxa1 vornr
      FROM afko AS a JOIN afvc AS b ON a~aufpl EQ b~aufpl
      INTO CORRESPONDING FIELDS OF TABLE t_afko
      FOR ALL ENTRIES IN t_viqmel
      WHERE aufnr EQ t_viqmel-aufnr.

    SELECT equnr spras eqktx
      FROM eqkt
      INTO CORRESPONDING FIELDS OF TABLE t_eqkt
      FOR ALL ENTRIES IN t_viqmel
      WHERE equnr EQ t_viqmel-equnr AND
            spras EQ sy-langu.

    SELECT a~aufnr b~rsnum b~vornr b~posnr meins bdmng maktx
      FROM caufv AS a JOIN resb AS b ON a~rsnum EQ b~rsnum
                      JOIN makt AS c ON b~matnr EQ c~matnr
      INTO CORRESPONDING FIELDS OF TABLE t_caufv
      FOR ALL ENTRIES IN t_viqmel
      WHERE a~aufnr EQ t_viqmel-aufnr.
  ENDIF.

  SELECT equnr tplnr
    FROM itob
    INTO CORRESPONDING FIELDS OF TABLE t_itob
    WHERE tplnr IN so_tplnr.
  DESCRIBE TABLE t_itob LINES va_mesin.
ENDFORM.                    "f_get_data

*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data USING fu_gjahr fu_mlow fu_mhigh.
  DATA: duration(22),
        downtime(22),
        strdt  LIKE sy-datum,
        enddt  LIKE sy-datum,
        ld_percen  TYPE p DECIMALS 2.

  SORT t_viqmel BY aufnr.
  SORT t_afko BY aufnr.
  SORT t_vdata BY aufnr.
  LOOP AT t_afko.
    t_vdata-aufnr  = t_afko-aufnr.
    t_vdata-aufpl  = t_afko-aufpl.
    t_vdata-vornr  = t_afko-vornr.
    t_vdata-aplzl  = t_afko-aplzl.
    t_vdata-ltxa1  = t_afko-ltxa1.

    READ TABLE t_viqmel WITH KEY aufnr = t_vdata-aufnr
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      t_vdata-qmnum  = t_viqmel-qmnum.
      t_vdata-strmn  = t_viqmel-strmn.
      t_vdata-strur  = t_viqmel-strur.
      t_vdata-ausbs  = t_viqmel-ausbs.
      t_vdata-auztb  = t_viqmel-auztb.
      t_vdata-maueh  = t_viqmel-maueh.
      t_vdata-auszt  = t_viqmel-auszt.
      t_vdata-qmtxt  = t_viqmel-qmtxt.

      CALL FUNCTION 'FUNC_LOCATION_READ'
        EXPORTING
          spras           = sy-langu
          tplnr           = t_viqmel-tplnr
        IMPORTING
          pltxt           = t_vdata-pltxt
        EXCEPTIONS
          iflot_not_found = 1
          iloa_not_found  = 2
          no_authority    = 3
          OTHERS          = 4.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        CLEAR: t_vdata-pltxt.
      ENDIF.

      READ TABLE t_eqkt WITH KEY equnr = t_viqmel-equnr.
      IF sy-subrc EQ 0.
        t_vdata-eqktx  = t_eqkt-eqktx.
      ELSE.
        CLEAR: t_vdata-eqktx.
      ENDIF.

      CLEAR: duration.
      PERFORM f_get_downtime USING fu_gjahr fu_mlow fu_mhigh
                                   t_vdata-strmn t_vdata-strur
                                   t_vdata-ausbs t_vdata-auztb
                             CHANGING t_vdata-jam t_vdata-menit
                                      duration.
      ON CHANGE OF t_afko-aufnr.
        ADD duration TO downtime.
        ADD 1 TO va_kasus.
      ENDON.

      LOOP AT t_caufv WHERE aufnr = t_vdata-aufnr AND
                            vornr = t_vdata-vornr.
        t_vdata-rsnum  = t_caufv-rsnum.
        t_vdata-posnr  = t_caufv-posnr.
        t_vdata-meins  = t_caufv-meins.
        t_vdata-bdmng  = t_caufv-bdmng.
        t_vdata-maktx  = t_caufv-maktx.
        APPEND t_vdata.
      ENDLOOP.
      IF sy-subrc NE 0.
        APPEND t_vdata.
      ENDIF.
      CLEAR: t_vdata.
    ENDIF.
  ENDLOOP.

  va_jam    = downtime DIV 60.
  va_menit  = downtime MOD 60.

  CONCATENATE va_period '01' INTO strdt.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = strdt
    IMPORTING
      last_day_of_month = enddt.
  PERFORM f_hitung_machine_hour USING strdt enddt
                                CHANGING va_kerja.
  va_kerja   = pa_totmh.
  ld_percen  = ( va_jam * 100 ) / va_kerja.
  va_percen  = ld_percen.
ENDFORM.                    " f_process_data

*---------------------------------------------------------------------*
*       FORM f_set_pf_status                                          *
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  SET PF-STATUS 'STANDARD'.
ENDFORM.                    " F_SET_PF_STATUS

*&---------------------------------------------------------------------*
*&      Module  status_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '100'.
ENDMODULE.                 " status_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  create_spreadsheet_interface  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE create_spreadsheet_interface OUTPUT.
  IF is_output IS INITIAL.
    PERFORM start_server USING 'Hatch cat'.
  ENDIF.
ENDMODULE.                 " create_spreadsheet_interface  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  formatting_output  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE formatting_output OUTPUT.
  DATA: lc_tabix(4),
        ld_row(4),
        ld_period(50),
        ld_downtime(30),
        ld_kasus(30),
        ld_kerja(30),
        ld_percen(30),
        ld_header(100),
        param1    TYPE i,
        param2    TYPE i,
        param3    TYPE i,
        param4    TYPE i.

  DATA: ld_flag(1),
        ld_qmnum  LIKE viqmel-qmnum.

  REFRESH: contents, rangesdef.

  IF is_output IS INITIAL.
    is_output = 'X'.
    CLEAR: columns_number.
    CASE so_monat-low.
      WHEN '01'.
        ld_period  = 'Januari'.
      WHEN '02'.
        ld_period  = 'Februari'.
      WHEN '03'.
        ld_period  = 'Maret'.
      WHEN '04'.
        ld_period  = 'April'.
      WHEN '05'.
        ld_period  = 'Mei'.
      WHEN '06'.
        ld_period  = 'Juni'.
      WHEN '07'.
        ld_period  = 'Juli'.
      WHEN '08'.
        ld_period  = 'Agustus'.
      WHEN '09'.
        ld_period  = 'September'.
      WHEN '10'.
        ld_period  = 'Oktober'.
      WHEN '11'.
        ld_period  = 'November'.
      WHEN '12'.
        ld_period  = 'Desember'.
    ENDCASE.

    IF so_monat-high IS NOT INITIAL.
      IF so_monat-high NE so_monat-low.
        CASE so_monat-high.
          WHEN '01'.
            CONCATENATE ld_period 'Januari' INTO ld_period
            SEPARATED BY '-'.
          WHEN '02'.
            CONCATENATE ld_period 'Februari' INTO ld_period
            SEPARATED BY '-'.
          WHEN '03'.
            CONCATENATE ld_period 'Maret' INTO ld_period
            SEPARATED BY '-'.
          WHEN '04'.
            CONCATENATE ld_period 'April' INTO ld_period
            SEPARATED BY '-'.
          WHEN '05'.
            CONCATENATE ld_period 'Mei' INTO ld_period
            SEPARATED BY '-'.
          WHEN '06'.
            CONCATENATE ld_period 'Juni' INTO ld_period
            SEPARATED BY '-'.
          WHEN '07'.
            CONCATENATE ld_period 'Juli' INTO ld_period
            SEPARATED BY '-'.
          WHEN '08'.
            CONCATENATE ld_period 'Agustus' INTO ld_period
            SEPARATED BY '-'.
          WHEN '09'.
            CONCATENATE ld_period 'September' INTO ld_period
            SEPARATED BY '-'.
          WHEN '10'.
            CONCATENATE ld_period 'Oktober' INTO ld_period
            SEPARATED BY '-'.
          WHEN '11'.
            CONCATENATE ld_period 'November' INTO ld_period
            SEPARATED BY '-'.
          WHEN '12'.
            CONCATENATE ld_period 'Desember' INTO ld_period
            SEPARATED BY '-'.
        ENDCASE.
      ENDIF.
    ENDIF.

    CASE 'X'.
      WHEN radio1.
        ld_header  = text-003.
        PERFORM set_content USING 2 2 ld_header.
        ld_header  = 'Malfunction Start'.
        PERFORM set_content USING 4 6 ld_header.
        ld_header  = 'Malfunction End'.
        PERFORM set_content USING 6 6 ld_header.
        ld_header  = 'Downtime'.
        PERFORM set_content USING 8 6 ld_header.

      WHEN radio2.
        ld_header  = text-004.
        PERFORM set_content USING 2 2 ld_header.
        ld_header  = 'Requirement Start'.
        PERFORM set_content USING 4 6 ld_header.
        ld_header  = 'Requirement End'.
        PERFORM set_content USING 6 6 ld_header.
        ld_header  = 'Waktu Perbaikan'.
        PERFORM set_content USING 8 6 ld_header.
    ENDCASE.

    CONCATENATE 'Bulan :' ld_period pa_gjahr INTO ld_period
    SEPARATED BY space.
    PERFORM set_content USING 2 4 ld_period.
    lc_tabix = 8.
    SORT t_vdata BY qmnum aufnr aufpl aplzl.
    LOOP AT t_vdata.
      lc_tabix       = lc_tabix + 1.
      IF ld_flag IS INITIAL.
        ld_flag  = 1.
        ld_qmnum  = t_vdata-qmnum.
      ELSE.
        IF t_vdata-qmnum EQ ld_qmnum.
          CLEAR: t_vdata-pltxt, t_vdata-eqktx, t_vdata-strmn, t_vdata-strur, t_vdata-ausbs,
                 t_vdata-auztb, t_vdata-ausbs, t_vdata-jam, t_vdata-menit, t_vdata-qmtxt.
        ENDIF.
      ENDIF.
      PERFORM formatting_contents_tab CHANGING lc_tabix.
      ld_qmnum  = t_vdata-qmnum.
      count = 1.
    ENDLOOP.

    param4  = lc_tabix.
    ld_row  = param1  = lc_tabix + 2.
    CASE 'X'.
      WHEN radio1.
        PERFORM set_content USING 2 ld_row 'Jumlah Breakdown'.
      WHEN radio2.
        PERFORM set_content USING 2 ld_row 'Jumlah Perbaikan'.
    ENDCASE.
    SHIFT va_kasus LEFT DELETING LEADING space.
    CONCATENATE ':' va_kasus 'Kasus' INTO ld_kasus
    SEPARATED BY space.
    PERFORM set_content USING 3 ld_row ld_kasus.
    ld_row  = ld_row + 1.
    PERFORM set_content USING 2 ld_row 'Jumlah Jam Kerja Mesin (Machine Hour)'.
    SHIFT va_kerja LEFT DELETING LEADING space.
    CONCATENATE ':' va_kerja 'Jam' INTO ld_kerja
    SEPARATED BY space.
    PERFORM set_content USING 3 ld_row ld_kerja.
    ld_row  = ld_row + 1.
    CASE 'X'.
      WHEN radio1.
        PERFORM set_content USING 2 ld_row 'Jumlah Downtime'.
      WHEN radio2.
        PERFORM set_content USING 2 ld_row 'Jumlah Waktu Perbaikan'.
    ENDCASE.
    CONCATENATE ':' va_jam 'Jam' va_menit 'Mnt' INTO ld_downtime
    SEPARATED BY space.
    PERFORM set_content USING 3 ld_row ld_downtime.
    ld_row  = ld_row + 1.
    CASE 'X'.
      WHEN radio1.
        PERFORM set_content USING 2 ld_row 'Total Downtime/Machine Hour'.
      WHEN radio2.
        PERFORM set_content USING 2 ld_row 'Total Waktu Perbaikan/Machine Hour'.
    ENDCASE.
    SHIFT va_percen LEFT DELETING LEADING space.
    CONCATENATE ':' va_percen '%' INTO ld_percen
    SEPARATED BY space.
    PERFORM set_content USING 3 ld_row ld_percen.

    ld_row  = param3  = ld_row + 3.
    PERFORM set_content USING 2 ld_row 'Dibuat oleh,'.
    PERFORM set_content USING 3 ld_row 'Disetujui oleh,'.
    PERFORM set_content USING 4 ld_row 'Diketahui oleh,'.
    ld_row  = ld_row + 4.

    PERFORM set_content USING 2 ld_row 'Nama :'.
    PERFORM set_content USING 3 ld_row 'Nama :'.
    PERFORM set_content USING 4 ld_row 'Nama :'.
    PERFORM set_content USING 5 ld_row 'Nama :'.
    ld_row  = ld_row + 1.
    PERFORM set_content USING 2 ld_row 'Engineering Supervisor'.
    PERFORM set_content USING 3 ld_row 'Engineering Manager'.
    PERFORM set_content USING 4 ld_row 'Plant Manager'.
    PERFORM set_content USING 5 ld_row 'GM Manufacturing'.
    param2  = ld_row.

    lc_tabix = lc_tabix - 8.
    PERFORM formatting_rangesdef_tab.
    PERFORM replace_word.
    PERFORM format_sheet USING param1 param2 param3 param4.
    PERFORM close_server.
  ENDIF.
ENDMODULE.                 " formatting_output  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  formatting_contents_tab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LC_TABIX  text
*----------------------------------------------------------------------*
FORM formatting_contents_tab CHANGING p_row.
  DATA: ld_name(70),
        ld_row(4),
        ld_downtime(30),
        ld_lines   TYPE i,
        ld_length  TYPE i,
        lt_lines   LIKE tline OCCURS 0 WITH HEADER LINE,
        ld_strpos  TYPE i,
        ld_endpos  TYPE i,
        ld_nama(132),
        ld_subrc   LIKE sy-subrc,
        ld_strdel  TYPE i,
        ld_enddel  TYPE i,
        ld_times   TYPE i,
        ld_ltxa1   LIKE afvc-ltxa1.

  PERFORM set_content USING 2 p_row t_vdata-pltxt.
  PERFORM set_content USING 3 p_row t_vdata-eqktx.
  PERFORM set_content_date USING 4 p_row t_vdata-strmn.
  PERFORM set_content_time USING 5 p_row t_vdata-strur t_vdata-strmn.
  PERFORM set_content_date USING 6 p_row t_vdata-ausbs.
  PERFORM set_content_time USING 7 p_row t_vdata-auztb t_vdata-ausbs.

  IF t_vdata-jam IS INITIAL.
    t_vdata-jam  = 0.
  ENDIF.
  IF t_vdata-menit IS INITIAL.
    t_vdata-menit  = 0.
  ENDIF.

  IF t_vdata-pltxt IS NOT INITIAL.
    CONCATENATE t_vdata-jam 'Jam' t_vdata-menit 'Mnt' INTO ld_downtime
    SEPARATED BY space.
  ENDIF.

  PERFORM set_content USING 8 p_row ld_downtime.
  PERFORM set_content USING 9 p_row t_vdata-qmtxt.

  ld_ltxa1 = t_vdata-ltxa1.
  PERFORM f_modify_text CHANGING ld_ltxa1.
  PERFORM set_content USING 10 p_row ld_ltxa1.

  PERFORM set_content USING 12 p_row t_vdata-maktx.
  PERFORM set_content_uom USING 13 p_row t_vdata-bdmng t_vdata-meins.

  CONCATENATE sy-mandt t_vdata-aufpl t_vdata-aplzl INTO ld_name.

  PERFORM f_read_text TABLES lt_lines
                      USING 'AVOT' ld_name 'AUFK' t_vdata-ltxa1.

  CLEAR: ld_lines.
  ld_row  = p_row.
  LOOP AT lt_lines.
    IF ld_lines IS INITIAL.
      ld_lines  = 1.
      SEARCH lt_lines-tdline FOR '['.
      IF sy-subrc EQ 0.
        ld_strpos  = sy-fdpos + 1.
      ELSE.
        ld_subrc   = sy-subrc.
      ENDIF.

      SEARCH lt_lines-tdline FOR ']'.
      IF sy-subrc EQ 0.
        ld_endpos  = sy-fdpos.
      ELSE.
        ld_subrc   = sy-subrc.
      ENDIF.

      ld_length  = ld_endpos - ld_strpos.
      ld_strdel  = ld_strpos - 1.
      ld_enddel  = ld_endpos + 1.
      ld_times   = ld_enddel - ld_strdel.

      IF ld_length IS NOT INITIAL.
        IF ld_subrc EQ 0.
          ld_name    = lt_lines-tdline+ld_strpos(ld_length).
          DO ld_times TIMES.
            REPLACE lt_lines-tdline+ld_strdel(1) WITH space INTO lt_lines-tdline+ld_strdel(1).
            ADD 1 TO ld_strdel.
          ENDDO.
        ELSE.
          ld_name    = 'NONAME'.
        ENDIF.
      ELSE.
        ld_name    = 'NONAME'.
      ENDIF.
      PERFORM set_content USING 14 ld_row ld_name.
    ENDIF.
    PERFORM set_content USING 11 p_row lt_lines-tdline.
    p_row  = p_row + 1.
  ENDLOOP.
  IF lt_lines[] IS INITIAL.
    p_row  = p_row + 1.
  ENDIF.
  p_row  = p_row - 1.
ENDFORM.                    " formatting_contents_tab

*&---------------------------------------------------------------------*
*&      Module  user_command_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " user_command_0100  INPUT

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
  REFRESH: so_tplnr.
  CLEAR: so_tplnr.
*  REFRESH: t_itab.
*  CLEAR: t_itab.
ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Form  format_sheet
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM format_sheet USING fu_param1 fu_param2 fu_param3 fu_param4.
  CALL METHOD document->execute_macro
    EXPORTING
      macro_string = 'Module1.Bold'
      no_flush     = no_flush
      param1       = fu_param1
      param2       = fu_param2
      param_count  = 2
    IMPORTING
      error        = error
      retcode      = retcode.
  CALL METHOD c_oi_errors=>show_message
    EXPORTING
      type = 'E'.

  CALL METHOD document->execute_macro
    EXPORTING
      macro_string = 'Module1.Alignment'
      no_flush     = no_flush
      param1       = fu_param3
      param2       = fu_param2
      param_count  = 2
    IMPORTING
      error        = error
      retcode      = retcode.
  CALL METHOD c_oi_errors=>show_message
    EXPORTING
      type = 'E'.

  CALL METHOD document->execute_macro
    EXPORTING
      macro_string = 'Module1.Border'
      no_flush     = no_flush
      param1       = fu_param4
      param_count  = 1
    IMPORTING
      error        = error
      retcode      = retcode.
  CALL METHOD c_oi_errors=>show_message
    EXPORTING
      type = 'E'.

ENDFORM.                    " format_sheet

*&---------------------------------------------------------------------*
*&      Form  F_READ_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0195   text
*      -->P_LD_NAME  text
*      -->P_0197   text
*----------------------------------------------------------------------*
FORM f_read_text  TABLES ft_lines STRUCTURE tline
                  USING fu_id fu_name fu_object fu_ltxa1.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = fu_id
      language                = sy-langu
      name                    = fu_name
      object                  = fu_object
    TABLES
      lines                   = ft_lines
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
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ft_lines-tdline  = fu_ltxa1.
    APPEND ft_lines.
  ENDIF.
ENDFORM.                    " F_READ_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_GET_DOWNTIME
*&---------------------------------------------------------------------*
FORM f_get_downtime  USING    fu_gjahr fu_mlow fu_mhigh fu_strdt fu_strtm fu_enddt fu_endtm
                     CHANGING fc_jam fc_menit fc_duration.

  DATA: e_duration  TYPE f,
        ld_strdt    LIKE sy-datum,
        ld_strtm    LIKE sy-uzeit,
        ld_enddt    LIKE sy-datum,
        ld_endtm    LIKE sy-uzeit,
        ld_period_str(6),
        ld_period_end(6),
        ld_datum    LIKE sy-datum.

  CASE 'X'.
    WHEN radio3.
      CONCATENATE fu_gjahr fu_mlow INTO ld_period_str.
      CONCATENATE fu_gjahr fu_mlow INTO ld_period_end.

    WHEN OTHERS.
      CONCATENATE fu_gjahr fu_mlow INTO ld_period_str.
      CONCATENATE fu_gjahr fu_mhigh INTO ld_period_end.
  ENDCASE.

* Get start date
  IF ld_period_str GT fu_strdt(6).
    CONCATENATE ld_period_str '01' INTO ld_strdt.
    ld_strtm  = '000000'.
  ELSEIF ld_period_str LE fu_strdt(6).
    ld_strdt  = fu_strdt.
    ld_strtm  = fu_strtm.
  ENDIF.

* Get end date
  IF fu_enddt IS INITIAL.
    IF ld_period_end LT sy-datum(6).
      CONCATENATE ld_period_end '01' INTO ld_enddt.
      CALL FUNCTION 'LAST_DAY_OF_MONTHS'
        EXPORTING
          day_in            = ld_enddt
        IMPORTING
          last_day_of_month = ld_enddt.
      ld_endtm  = '240000'.
    ELSEIF ld_period_end EQ sy-datum(6).
      ld_enddt  = sy-datum.
      ld_endtm  = sy-uzeit.
    ENDIF.
  ELSE.
    IF ld_period_end LT fu_enddt(6).
      CONCATENATE ld_period_end '01' INTO ld_enddt.
      CALL FUNCTION 'LAST_DAY_OF_MONTHS'
        EXPORTING
          day_in            = ld_enddt
        IMPORTING
          last_day_of_month = ld_enddt.
      ld_endtm  = '240000'.
    ELSEIF ld_period_end GE fu_enddt(6).
      ld_enddt  = fu_enddt.
      ld_endtm  = fu_endtm.
    ENDIF.
  ENDIF.


  CALL FUNCTION 'COPF_DETERMINE_DURATION'
    EXPORTING
      i_start_date       = ld_strdt
      i_start_time       = ld_strtm
      i_end_date         = ld_enddt
      i_end_time         = ld_endtm
      i_unit_of_duration = 'MIN'
      i_factory_calendar = 'M1'
    IMPORTING
      e_duration         = e_duration.

  IF sy-subrc EQ 0.
    CALL FUNCTION 'FLTP_CHAR_CONVERSION'
      EXPORTING
        input = e_duration
        ivalu = 'X'
        decim = 0
      IMPORTING
        flstr = fc_duration.

    IF sy-subrc EQ 0.
      fc_jam    = fc_duration DIV 60.
      fc_menit  = fc_duration MOD 60.
    ELSE.
      fc_jam = fc_menit = 0.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DOWNTIME

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  CASE 'X'.
    WHEN radio3.
      LOOP AT SCREEN.
        IF screen-group1 = 'TOT'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN OTHERS.
      LOOP AT SCREEN.
        IF screen-group1 = 'CHA'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'PER'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA: ld_error(50) VALUE 'Error in period',
        ld_mess(50) VALUE 'Fill in all required entry fields'.

  CONCATENATE pa_gjahr so_monat-low INTO va_period.
  IF va_period GT sy-datum(6).
    LOOP AT SCREEN.
      IF screen-group1 EQ 'GJA' OR
        screen-group1 EQ 'SMO'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH ld_error.
    CLEAR: sscrfields-ucomm.
  ENDIF.
  IF so_monat-high IS INITIAL.
    so_monat-high  = so_monat-low.
  ENDIF.
  CONCATENATE pa_gjahr so_monat-high INTO va_period.
  IF va_period GT sy-datum(6).
    LOOP AT SCREEN.
      IF screen-group1 EQ 'GJA' OR
        screen-group1 EQ 'SMO'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH ld_error.
    CLEAR: sscrfields-ucomm.
  ENDIF.

  IF pa_iwerk IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'IWE'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH ld_mess.
    CLEAR: sscrfields-ucomm.
  ENDIF.

  IF so_monat-low IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'SMO'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH ld_mess.
    CLEAR: sscrfields-ucomm.
  ELSE.
    IF so_monat-high IS INITIAL.
      so_monat-high  = so_monat-low.
    ELSE.
      IF so_monat-low GT so_monat-high.
        LOOP AT SCREEN.
          IF screen-group1 EQ 'SMO'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_period.
        CLEAR: sscrfields-ucomm.
      ENDIF.
    ENDIF.
  ENDIF.

  CASE 'X'.
    WHEN radio3.
      IF pa_perce IS INITIAL.
        LOOP AT SCREEN.
          IF screen-group1 EQ 'PER'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ENDIF.

    WHEN OTHERS.
      IF pa_totmh IS INITIAL.
        LOOP AT SCREEN.
          IF screen-group1 EQ 'TOT'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH ld_mess.
        CLEAR: sscrfields-ucomm.
      ENDIF.
  ENDCASE.

  IF pa_gjahr IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'GJA'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH ld_mess.
    CLEAR: sscrfields-ucomm.
  ENDIF.

  IF so_tplnr[] IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'TPL'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH ld_mess.
    CLEAR: sscrfields-ucomm.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_HITUNG_MACHINE_HOUR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_STRDT  text
*      -->FU_ENDDT  text
*      <--FC_KERJA  text
*----------------------------------------------------------------------*
FORM f_hitung_machine_hour  USING    fu_strdt
                                     fu_enddt
                            CHANGING fc_kerja.

  DATA: holidays  LIKE iscal_day OCCURS 0 WITH HEADER LINE,
        ld_day    TYPE i.

  CALL FUNCTION 'HOLIDAY_GET'
    EXPORTING
      holiday_calendar = 'M1'
      factory_calendar = 'M1'
      date_from        = fu_strdt
      date_to          = fu_enddt
    TABLES
      holidays         = holidays.

  DESCRIBE TABLE holidays LINES ld_day.
  IF sy-subrc EQ 0.
    fc_kerja  = ( ( ( fu_enddt - fu_strdt ) + 1 ) - ld_day ) * 24.
    fc_kerja  = fc_kerja * va_mesin.
  ENDIF.
ENDFORM.                    " F_HITUNG_MACHINE_HOUR

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA_RADIO3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data_radio3 .
  DATA: ld_monat   LIKE bsis-monat,
        ld_monat1  LIKE bsis-monat,
        duration(22),
        breakdown(10),
        jam(10),
        menit(4),
        ld_period(6),
        down01(22), down02(22), down03(22), down04(22), down05(22), down06(22),
        down07(22), down08(22), down09(22), down10(22), down11(22), down12(22),
        breakdown01(10), breakdown02(10), breakdown03(10), breakdown04(10),
        breakdown05(10), breakdown06(10), breakdown07(10), breakdown08(10),
        breakdown09(10), breakdown10(10), breakdown11(10), breakdown12(10).

  SORT t_viqmel BY aufnr.
  SORT t_afko BY aufnr.
  SORT t_vdata BY aufnr.

  DELETE ADJACENT DUPLICATES FROM t_afko COMPARING aufnr.
  LOOP AT t_afko.
    ld_monat  = so_monat-low.
    READ TABLE t_viqmel WITH KEY aufnr = t_afko-aufnr
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      DO va_times TIMES.
        CONCATENATE pa_gjahr ld_monat INTO ld_period.
        IF t_viqmel-strmn(6) LE ld_period.
          IF t_viqmel-ausbs IS NOT INITIAL.
            IF t_viqmel-ausbs(6) GE ld_period.
              PERFORM f_get_downtime USING pa_gjahr ld_monat ''
                                           t_viqmel-strmn t_viqmel-strur
                                           t_viqmel-ausbs t_viqmel-auztb
                                     CHANGING jam menit duration.
              breakdown  = 1.
            ELSE.
              CLEAR: duration, breakdown.
            ENDIF.
          ELSE.
            PERFORM f_get_downtime USING pa_gjahr ld_monat ''
                                         t_viqmel-strmn t_viqmel-strur
                                         t_viqmel-ausbs t_viqmel-auztb
                                   CHANGING jam menit duration.
            breakdown  = 1.
          ENDIF.
        ELSE.
          CLEAR: duration, breakdown.
        ENDIF.

        CASE ld_monat.
          WHEN '01'.
            ADD duration TO down01.
            ADD breakdown TO breakdown01.
          WHEN '02'.
            ADD duration TO down02.
            ADD breakdown TO breakdown02.
          WHEN '03'.
            ADD duration TO down03.
            ADD breakdown TO breakdown03.
          WHEN '04'.
            ADD duration TO down04.
            ADD breakdown TO breakdown04.
          WHEN '05'.
            ADD duration TO down05.
            ADD breakdown TO breakdown05.
          WHEN '06'.
            ADD duration TO down06.
            ADD breakdown TO breakdown06.
          WHEN '07'.
            ADD duration TO down07.
            ADD breakdown TO breakdown07.
          WHEN '08'.
            ADD duration TO down08.
            ADD breakdown TO breakdown08.
          WHEN '09'.
            ADD duration TO down09.
            ADD breakdown TO breakdown09.
          WHEN '10'.
            ADD duration TO down10.
            ADD breakdown TO breakdown10.
          WHEN '11'.
            ADD duration TO down11.
            ADD breakdown TO breakdown11.
          WHEN '12'.
            ADD duration TO down12.
            ADD breakdown TO breakdown12.
        ENDCASE.
        ADD 1 TO ld_monat.
      ENDDO.
    ENDIF.
  ENDLOOP.

*  IF pa_chart IS NOT INITIAL.
*    IF so_monat-low GT 1.
*      ld_monat  = so_monat-low - 1.
*      DO ld_monat TIMES.
*        ADD 1 TO ld_monat1.
*        t_radio3-monat  = ld_monat1.
*        t_radio3-gjahr  = pa_gjahr.
*        CONCATENATE ld_monat1 pa_gjahr INTO t_radio3-period
*        SEPARATED BY '-'.
*        APPEND t_radio3.
*      ENDDO.
*    ENDIF.
*  ENDIF.

  ld_monat  = so_monat-low.
  DO va_times TIMES.
    t_radio3-monat  = ld_monat.
    t_radio3-gjahr  = pa_gjahr.
    CONCATENATE ld_monat pa_gjahr INTO t_radio3-period
    SEPARATED BY '-'.
    CASE ld_monat.
      WHEN '01'.
        PERFORM f_calc_radio3 USING ld_monat down01 breakdown01
                              CHANGING t_radio3-tdtjm t_radio3-tdtmn
                                       t_radio3-perdt t_radio3-brdow.
      WHEN '02'.
        PERFORM f_calc_radio3 USING ld_monat down02 breakdown02
                              CHANGING t_radio3-tdtjm t_radio3-tdtmn
                                       t_radio3-perdt t_radio3-brdow.
      WHEN '03'.
        PERFORM f_calc_radio3 USING ld_monat down03 breakdown03
                              CHANGING t_radio3-tdtjm t_radio3-tdtmn
                                       t_radio3-perdt t_radio3-brdow.
      WHEN '04'.
        PERFORM f_calc_radio3 USING ld_monat down04 breakdown04
                              CHANGING t_radio3-tdtjm t_radio3-tdtmn
                                       t_radio3-perdt t_radio3-brdow.
      WHEN '05'.
        PERFORM f_calc_radio3 USING ld_monat down05 breakdown05
                              CHANGING t_radio3-tdtjm t_radio3-tdtmn
                                       t_radio3-perdt t_radio3-brdow.
      WHEN '06'.
        PERFORM f_calc_radio3 USING ld_monat down06 breakdown06
                              CHANGING t_radio3-tdtjm t_radio3-tdtmn
                                       t_radio3-perdt t_radio3-brdow.
      WHEN '07'.
        PERFORM f_calc_radio3 USING ld_monat down07 breakdown07
                              CHANGING t_radio3-tdtjm t_radio3-tdtmn
                                       t_radio3-perdt t_radio3-brdow.
      WHEN '08'.
        PERFORM f_calc_radio3 USING ld_monat down08 breakdown08
                              CHANGING t_radio3-tdtjm t_radio3-tdtmn
                                       t_radio3-perdt t_radio3-brdow.
      WHEN '09'.
        PERFORM f_calc_radio3 USING ld_monat down09 breakdown09
                              CHANGING t_radio3-tdtjm t_radio3-tdtmn
                                       t_radio3-perdt t_radio3-brdow.
      WHEN '10'.
        PERFORM f_calc_radio3 USING ld_monat down10 breakdown10
                              CHANGING t_radio3-tdtjm t_radio3-tdtmn
                                       t_radio3-perdt t_radio3-brdow.
      WHEN '11'.
        PERFORM f_calc_radio3 USING ld_monat down11 breakdown11
                              CHANGING t_radio3-tdtjm t_radio3-tdtmn
                                       t_radio3-perdt t_radio3-brdow.
      WHEN '12'.
        PERFORM f_calc_radio3 USING ld_monat down12 breakdown12
                              CHANGING t_radio3-tdtjm t_radio3-tdtmn
                                       t_radio3-perdt t_radio3-brdow.
    ENDCASE.
    t_radio3-jmlmsn = va_mesin.
    t_radio3-defal = pa_perce.
    APPEND t_radio3.
    ADD 1 TO ld_monat.
  ENDDO.

*  IF pa_chart IS NOT INITIAL.
*    CLEAR: t_radio3.
*    IF so_monat-high LT 12.
*      ld_monat   = 12 - so_monat-high.
*      ld_monat1  = so_monat-high + 1.
*      DO ld_monat TIMES.
*        t_radio3-monat  = ld_monat1.
*        t_radio3-gjahr  = pa_gjahr.
*        CONCATENATE ld_monat1 pa_gjahr INTO t_radio3-period
*        SEPARATED BY '-'.
*        APPEND t_radio3.
*        ADD 1 TO ld_monat1.
*      ENDDO.
*    ENDIF.
*  ENDIF.
ENDFORM.                    " F_PROCESS_DATA_RADIO3

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_data .
  PERFORM f_alv TABLES t_radio3.
ENDFORM.                    " F_PRINT_DATA

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

  PERFORM f_fieldcatg USING ft_report:
    'MONAT' 'ZPMSTBD' 'MONAT' '' '' '' '' '' '' '' '' '' '' '',
    'GJAHR' 'ZPMSTBD' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '',
    'TDTJM' 'ZPMSTBD' 'TDTJM' '' '' '' '' '' '' '' '' '' '' '',
    'TDTMN' 'ZPMSTBD' 'TDTMN' '' '' '' '' '' '' '' '' '' '' '',
    'PERDT' 'ZPMSTBD' 'PERDT' '' '' '' '' '' '' '' '' '' '' '',
    'BRDOW' 'ZPMSTBD' 'BRDOW' '' '' '' '' '' '' '' '' '' '' '',
    'JMLMSN' 'ZPMSTBD' 'JMLMSN' '' '' '' '' '' '' '' '' '' '' '',
    'DEFAL' 'ZPMSTBD' 'DEFAL' '' '' '' '' '' '' '' '' '' '' ''.
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

*  CLEAR ld_sort.
*  ld_sort-fieldname = 'WERKS'.
*  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
*  APPEND ld_sort TO fu_sort.
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

*&---------------------------------------------------------------------*
*&      Module  STATUS_0110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0110 OUTPUT.
  DATA: ld_monat  LIKE bsis-monat.

  SET PF-STATUS '100'.

  IF first_call IS INITIAL.
*   display graphic
    REFRESH values. REFRESH column_texts.
    values-rowtxt = co_gfw_prog_row1.
    values-val1   = pa_perce.
    values-val2   = pa_perce.
    values-val3   = pa_perce.
    values-val4   = pa_perce.
    values-val5   = pa_perce.
    values-val6   = pa_perce.
    values-val7   = pa_perce.
    values-val8   = pa_perce.
    values-val9   = pa_perce.
    values-val10   = pa_perce.
    values-val11   = pa_perce.
    values-val12   = pa_perce.
    APPEND values.

    values-rowtxt = co_gfw_prog_row2.
    LOOP AT t_radio3.
      CASE t_radio3-monat.
        WHEN '01'.
          values-val1   = t_radio3-perdt.
        WHEN '02'.
          values-val2   = t_radio3-perdt.
        WHEN '03'.
          values-val3   = t_radio3-perdt.
        WHEN '04'.
          values-val4   = t_radio3-perdt.
        WHEN '05'.
          values-val5   = t_radio3-perdt.
        WHEN '06'.
          values-val6   = t_radio3-perdt.
        WHEN '07'.
          values-val7   = t_radio3-perdt.
        WHEN '08'.
          values-val8   = t_radio3-perdt.
        WHEN '09'.
          values-val9   = t_radio3-perdt.
        WHEN '10'.
          values-val10   = t_radio3-perdt.
        WHEN '11'.
          values-val11   = t_radio3-perdt.
        WHEN '12'.
          values-val12   = t_radio3-perdt.
      ENDCASE.
      APPEND values.
    ENDLOOP.

    DO 12 TIMES.
      ADD 1 TO ld_monat.
      CONCATENATE ld_monat pa_gjahr INTO column_texts-coltxt
      SEPARATED BY '-'.
      APPEND column_texts.
    ENDDO.

    CALL FUNCTION 'GFW_PRES_SHOW'
      EXPORTING
        container         = 'CONTAINER'
        presentation_type = gfw_prestype_lines
      TABLES
        values            = values
        column_texts      = column_texts
      EXCEPTIONS
        error_occurred    = 1
        OTHERS            = 2.
    IF sy-subrc <> 0.
*     ...add your error handling here
      LEAVE PROGRAM.
    ENDIF.
    first_call = 1.
  ENDIF. "//firstcall initial

** USAGE allowed in SAP internal test reports, only
*  PERFORM auto_test_pbo USING 'EXIT'.
ENDMODULE.                 " STATUS_0110  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0110 INPUT.
  CASE okcode.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0110  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_CALC_RADIO3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_calc_radio3  USING    fu_monat fu_downtime fu_breakdown
                    CHANGING fc_tdtjm fc_tdtmn fc_perdt fc_brdow.

  DATA: strdt      LIKE sy-datum,
        enddt      LIKE sy-datum,
        ld_kerja(10).


  CONCATENATE pa_gjahr fu_monat '01' INTO strdt.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = strdt
    IMPORTING
      last_day_of_month = enddt.
  PERFORM f_hitung_machine_hour USING strdt enddt
                                CHANGING ld_kerja.

  fc_tdtjm  = fu_downtime DIV 60.
  fc_tdtmn  = fu_downtime MOD 60.
  fc_perdt  = ( fc_tdtjm * 100 ) / ld_kerja.
  fc_brdow  = fu_breakdown.
ENDFORM.                    " F_CALC_RADIO3

*&---------------------------------------------------------------------*
*&      Form  F_GET_LINES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_lines  USING    fu_flag fu_gjahr
                  CHANGING fc_monat fc_gjahr fc_perdt fc_period.
  fc_monat  = fu_flag.
  fc_gjahr  = fu_gjahr.
  CONCATENATE fu_flag fu_gjahr INTO fc_period
  SEPARATED BY '-'.
  fc_perdt  = 15 / 10.
ENDFORM.                    " F_GET_LINES

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_TEXT
*&---------------------------------------------------------------------*
FORM f_modify_text  CHANGING    fc_text.
  DATA: ld_subrc   LIKE sy-subrc,
        ld_length  TYPE i,
        ld_strpos  TYPE i,
        ld_endpos  TYPE i,
        ld_strdel  TYPE i,
        ld_enddel  TYPE i,
        ld_times   TYPE i.

  SEARCH fc_text FOR '['.
  IF sy-subrc EQ 0.
    ld_strpos  = sy-fdpos + 1.
  ELSE.
    ld_subrc   = sy-subrc.
  ENDIF.

  SEARCH fc_text FOR ']'.
  IF sy-subrc EQ 0.
    ld_endpos  = sy-fdpos.
  ELSE.
    ld_subrc   = sy-subrc.
  ENDIF.

  ld_length  = ld_endpos - ld_strpos.
  ld_strdel  = ld_strpos - 1.
  ld_enddel  = ld_endpos + 1.
  ld_times   = ld_enddel - ld_strdel.

  IF ld_length IS NOT INITIAL.
    IF ld_subrc EQ 0.
      DO ld_times TIMES.
        REPLACE fc_text+ld_strdel(1) WITH space INTO fc_text+ld_strdel(1).
        ADD 1 TO ld_strdel.
      ENDDO.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_TEXT
