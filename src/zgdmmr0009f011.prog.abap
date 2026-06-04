*----------------------------------------------------------------------*
*   INCLUDE ZGDPPR0012F011                                             *
*----------------------------------------------------------------------*
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
  PERFORM f_alv_variant_exist USING   p_vari
                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
*   I_INTERFACE_CHECK              = ' '
*   I_BYPASSING_BUFFER             =
*   I_BUFFER_ACTIVE                = ' '
    i_callback_program             = d_repid
    i_callback_pf_status_set       = 'F_SET_PF_STATUS'
    i_callback_user_command        = 'F_USER_COMMAND'
*   I_STRUCTURE_NAME               =
    is_layout                      = d_layout
    it_fieldcat                    = t_alv_fieldcat[]
*   IT_EXCLUDING                   =
*   IT_SPECIAL_GROUPS              =
    it_sort                        = t_alv_isort[]
*   IT_FILTER                      =
*   IS_SEL_HIDE                    =
    i_default                      = 'X'
    i_save                         = 'A'
    is_variant                     = d_alv_variant
    it_events                      = t_alv_event[]
    it_event_exit                  = t_event_exit[]
    is_print                       = d_print
*   IS_REPREP_ID                   =
*   I_SCREEN_START_COLUMN          = 0
*   I_SCREEN_START_LINE            = 0
*   I_SCREEN_END_COLUMN            = 0
*   I_SCREEN_END_LINE              = 0
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER        =
*   ES_EXIT_CAUSED_BY_USER         =
    TABLES
      t_outtab                       = ft_report
   EXCEPTIONS
     program_error                  = 1
     OTHERS                         = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.

  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING ft_report:
    'NO' '' '' '' '4' 'No' '' '' '' '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '42'
    'Nama Obat Jadi,Bentuk Sediaan dan Kekuatan'
    '' '' '' '' '' '' '' '' '',
    'BASME' 'S933' 'BASME' '' '14' 'Satuan Kemasan' '' '' '' '' '' '' ''
    '' 'X',
    'MENGE' 'S933' 'MENGE' '' '' 'Jumlah' '' '' '' '' '' '' 'BASME'
    '' 'X',
    'DMBTR' 'S933' 'DMBTR' '' '' 'Nilai (Rp)' '' '' '' 'IDR' '' '' ''
    '' 'X',
    'HWAER' 'S933' 'HWAER' '' '' 'Currency' '' '' '' '' '' '' '' '' '',
    'NAME2' 'T001W' 'NAME2' '' '' 'Importir' '' '' '' '' '' '' '' '' '',
    'NAME1' 'LFA1' 'NAME1' '' ''
    'Asal (Nama Industri dan Negara)'
    '' '' '' '' '' '' '' '' ''.

ENDFORM.                    " F_FIELDCAT

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

  CLEAR ft_events.
  ft_events-name = slis_ev_end_of_list.
  ft_events-form = 'F_END_OF_LIST'.
  APPEND ft_events.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.

***changed by Rahmadi -- remove header
*  PERFORM f_hdr_uline.
  PERFORM f_hdr_line_page USING ''.
*  PERFORM f_hdr_line1 USING ''.
*  PERFORM f_hdr_line2 USING ''.
*  PERFORM f_hdr_line3 USING ''.
*  PERFORM f_hdr_uline.

  SKIP 1.
  PERFORM f_hdr_line4 USING ''.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE_PAGE
*&---------------------------------------------------------------------*
*       Header line with report, title and page
*----------------------------------------------------------------------*
FORM f_hdr_line_page USING fu_company.
  DATA:
    page_number(10) VALUE 'Page: nnnn',
    progname(42) VALUE '',
    ld_progname(20),
    page(4).

*--- Page number
  page = sy-pagno.
  REPLACE 'nnnn' WITH page INTO page_number.
*  IF sy-cprog EQ sy-repid.
*    REPLACE 'xx' WITH sy-repid INTO progname.
*  ELSE.
*    CONCATENATE sy-repid '(' sy-cprog ')' INTO ld_progname.
*    REPLACE 'xx' WITH ld_progname INTO progname.
*  ENDIF.

*--- Output line
  PERFORM f_hdr_pad_page USING progname fu_company page_number.
ENDFORM.                    " F_HDR_LINE1

*&---------------------------------------------------------------------*
*&      Form  F_HDR_PAD_PAGE
*&---------------------------------------------------------------------*
*       Prepare the variable with the title text spaced correctly
*----------------------------------------------------------------------*
FORM f_hdr_pad_page USING v_left_text v_middle_text v_right_text.

  DATA:
      page_width TYPE i,       " Width of page
      middle_length TYPE i,    " Length of title text
      left_length TYPE i,      " Length of left text
      right_length TYPE i,     " Length of right text
      left_start TYPE i,       " Position on line for start of left tex
      middle_start TYPE i,     " Position on line for start of middl tex
      right_start TYPE i.      " Position on line for start of right tex

*--- Start with a blank title
  CLEAR d_hdr_title.
  page_width = sy-linsz - 1.

*--- Compute space on either side of title allowing vertical border
  COMPUTE middle_length = strlen( v_middle_text ).
  COMPUTE left_length = strlen( v_left_text ).
  COMPUTE right_length = strlen( v_right_text ).

  COMPUTE middle_start = ( sy-linsz - middle_length ) / 2.

*--- Allow for vertical lines
  left_start = 0.
  IF d_hdr_rpt_lines = 'X'.
    d_hdr_title(1) = sy-vline.
    d_hdr_title+page_width(1) = sy-vline.
    left_start = 1.
  ENDIF.
  right_start = sy-linsz - left_start - right_length - 1.
  WRITE:/ ''.
*--- Insert texts
  IF left_length <> 0.
*    d_hdr_title+left_start(left_length) = v_left_text.
    WRITE AT (left_length) v_left_text.
  ENDIF.
  IF middle_length <> 0.
    WRITE AT middle_start(middle_length) v_middle_text.
*    d_hdr_title+middle_start(middle_length) = v_middle_text.
  ENDIF.
  IF right_length <> 0.
    WRITE AT right_start(right_length) v_right_text.
*    d_hdr_title+right_start(right_length) = v_right_text.
  ENDIF.
*  write at sy-linsz sy-vline.
ENDFORM.                    " F_HDR_PAD_PAGE

*&---------------------------------------------------------------------*
*&      Form  f_hdr_line4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0617   text
*----------------------------------------------------------------------*
FORM f_hdr_line4 USING    value(p_0617).
  DATA: l_start          TYPE i,
        l_right1         TYPE i,
        l_right2         TYPE i,
        l_right3         TYPE i,
        l_length         TYPE i,
        l_title(100),
        l_plant(60)      VALUE 'NAMA INDUSTRI FARMASI : ',
        l_alamat(100)    VALUE 'ALAMAT                : ',
        l_ort01(100)     VALUE '                       ',
        l_tahun(100)     VALUE 'TAHUN :                ',
        l_bulan(100)     VALUE 'BULAN :                ',
        ld_mnr LIKE t247-mnr,
        ld_ltx LIKE t247-ltx,
        ld_kep(100) VALUE 'Keputusan Menteri Keuangan RI',
        ld_nom(100) VALUE 'Nomor: Kep-092/BC.4/2003',
        ld_tang(100) VALUE 'Tanggal: 23 Desember 2003'.

**---Lettering number
*  COMPUTE l_length = strlen( ld_kep ).
*  COMPUTE l_right1 = sy-linsz - l_length.
*  COMPUTE l_length = strlen( ld_nom ).
*  COMPUTE l_right2 = sy-linsz - l_length.
*  COMPUTE l_length = strlen( ld_tang ).
*  COMPUTE l_right3 = sy-linsz - l_length.

*---Title
  l_title = 'LAPORAN REALISASI IMPORT OBAT JADI'.
  COMPUTE l_length = strlen( l_title ).
  COMPUTE l_start = ( sy-linsz - l_length ) / 2.

*---Period
  SELECT SINGLE mnr ltx INTO (ld_mnr, ld_ltx)
                        FROM t247
                        WHERE mnr = p_period+4(2) AND
                              spras = 'i'.
  CONCATENATE l_tahun p_period(4) INTO l_tahun
    SEPARATED BY space.
  CONCATENATE l_bulan ld_ltx INTO l_bulan
    SEPARATED BY space.

*--- Plant
*-Changed by Rahmadi: VA_NAME1 to VA_NAME2
  CONCATENATE l_plant va_name2 INTO l_plant
    SEPARATED BY space.
*--- Alamat
  CONCATENATE l_alamat va_stras INTO l_alamat
    SEPARATED BY space.
  CONCATENATE l_ort01 va_ort01 INTO l_ort01
    SEPARATED BY space.

*--- output line
  WRITE: /l_start l_title.
  SKIP 1.
  WRITE: / l_plant,
         / l_alamat,
         / l_ort01.
  SKIP 1.
  WRITE: /1 l_bulan,
          30 l_tahun.
ENDFORM.                    " f_hdr_line4

*---------------------------------------------------------------------*
*       FORM f_end_of_list                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_end_of_list.

  SKIP 1.
*  PERFORM f_hdr_uline.
*  PERFORM f_ftr_line1 USING ''.
*  PERFORM f_hdr_uline.
*  PERFORM f_ftr_line2 USING ''.
*  PERFORM f_hdr_uline.
  PERFORM f_ftr_line3 USING ''.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  f_ftr_line1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1430   text
*----------------------------------------------------------------------*
FORM f_ftr_line1 USING    value(p_1430).
  DATA: l_footer1(100)
  VALUE 'SOLE DISTRIBUTOR :     PT.TEMPO;PT SUPRA USADHATAMA'.
*--- output line
  PERFORM f_hdr_pad_title USING l_footer1 ' ' ' '.
ENDFORM.                    " f_ftr_line1

*&---------------------------------------------------------------------*
*&      Form  f_ftr_line2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1436   text
*----------------------------------------------------------------------*
FORM f_ftr_line2 USING    value(p_1436).
  DATA: l_footer2(100) VALUE 'DISTRIBUTOR LAIN :     -'.
*--- output line
  PERFORM f_hdr_pad_title USING l_footer2 ' ' ' '.
ENDFORM.                    " f_ftr_line2

*&---------------------------------------------------------------------*
*&      Form  f_ftr_line3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1442   text
*----------------------------------------------------------------------*
FORM f_ftr_line3 USING    value(p_1442).
  DATA:  l_date(10),
         l_date1(30),
         l_sik(24) VALUE 'SIK.',
         l_sign(45),
         l_start    TYPE i,
         l_length   TYPE i,
         l_uline    TYPE i.

  WRITE sy-datum DD/MM/YYYY TO l_date.
  CONCATENATE va_ort01 ',' l_date INTO l_date1
    SEPARATED BY space.
  l_length = 45.
  l_start = sy-linsz - l_length.

  CONCATENATE l_sik p_sik INTO l_sik
     SEPARATED BY space.

  WRITE AT /l_start(l_length) l_date1 CENTERED.
  WRITE AT /l_start(l_length) 'Apoteker Penanggung Jawab' CENTERED.

  IF NOT p_sign IS INITIAL.
    CONCATENATE '(' p_sign ')' INTO l_sign SEPARATED BY space.
  ENDIF.
  SKIP 4.
  COMPUTE l_uline = strlen( l_sign ).
  WRITE AT /l_start(l_length) l_sign CENTERED.
  WRITE AT /l_start(l_length) sy-uline(l_length) CENTERED.
  WRITE AT /l_start(l_length) l_sik CENTERED.

ENDFORM.                    " f_ftr_line3
