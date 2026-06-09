*----------------------------------------------------------------------*
*   INCLUDE ZGDPPR0012F012                                             *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM f_alv1                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_DATA                                                       *
*---------------------------------------------------------------------*
FORM f_alv1 TABLES ft_report.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat1   TABLES  ft_report.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield1  USING   t_alv_isort[].
  PERFORM f_build_event1      TABLES  t_alv_event[].
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
*       FORM f_fieldcat1                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat1 TABLES ft_report.

  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING ft_report:
    'MATNR' 'MARA' 'MATNR' '' '' '' '' '' '' '' '' '' '' '',
    'MAKTX' '' '' '' '40' 'NAMA OBAT' '' '' '' '' '' '' '' '',
    'MEINS' 'MSEG' 'MEINS' '' '' '' '' '' '' '' '' '' '' '',
    'MSEH6' 'T006A' 'MSEH6' '' '' 'SATUAN' '' '' '' '' '' '' '' '',
    'MENGE' '' '' '' '18' 'JUMLAH PRODUKSI' '' '' '' '' '' '' 'MEINS'
    '',
    'SATUAN' '' '' '' '18' 'SATUAN (Rp.)' '' '' '' 'IDR' '' '' '' '',
    'NILAI' '' '' '' '20' 'NILAI (Rp.)' 'X' '' '' 'IDR' '' '' '' ''.
*    'WAERS' 'TCURC' 'WAERS' '' '' '' '' '' '' '' '' '' '' ''.

ENDFORM.                    " F_FIELDCAT

*---------------------------------------------------------------------*
*       FORM f_build_event1                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_EVENTS                                                     *
*---------------------------------------------------------------------*
FORM f_build_event1 TABLES ft_events LIKE t_events.

  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE1'.
  APPEND ft_events.

  CLEAR ft_events.
  ft_events-name = slis_ev_end_of_list.
  ft_events-form = 'F_END_OF_LIST1'.
  APPEND ft_events.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_build_sortfield1                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_SORT                                                       *
*---------------------------------------------------------------------*
FORM f_build_sortfield1 USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'MAKTX'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_top_of_page1                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page1.

***changed by Rahmadi -- remove header
*  PERFORM f_hdr_uline.
*  PERFORM f_hdr_line1 USING ''.
  PERFORM f_hdr_line_page USING ''.
*  PERFORM f_hdr_line2 USING ''.
*  PERFORM f_hdr_line3 USING ''.
*  PERFORM f_hdr_uline.

  SKIP 1.
  PERFORM f_hdr_line5 USING ''.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  f_hdr_line5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0281   text
*----------------------------------------------------------------------*
FORM f_hdr_line5 USING    value(p_0281).
  DATA: l_semester(100) VALUE 'SEMESTER : ',
        l_tahun(100)    VALUE 'TAHUN    : ',
        l_title(100),
        l_plant(60)      VALUE 'NAMA INDUSTRI FARMASI : ',
        l_alamat(100)    VALUE 'ALAMAT                : ',
        l_ort01(100)     VALUE '                       ',
        l_length        TYPE i,
        l_start         TYPE i,
        l_pos TYPE i.

  l_pos = sy-linsz - 15.

*--- Title
  l_title = 'LAPORAN PRODUKSI OBAT TRADISIONAL'.
  COMPUTE l_length = strlen( l_title ).
  COMPUTE l_start = ( sy-linsz - l_length ) / 2.

*--- Plant
*-Changed by Rahmadi: VA_NAME1 to VA_NAME2
  CONCATENATE l_plant va_name2 INTO l_plant
    SEPARATED BY space.
*--- Alamat
  CONCATENATE l_alamat va_stras INTO l_alamat
    SEPARATED BY space.
  CONCATENATE l_ort01 va_ort01 INTO l_ort01
    SEPARATED BY space.

*--- Semester
  IF radio5 EQ 'X'.
    CONCATENATE l_semester 'I' INTO l_semester
      SEPARATED BY space.
  ELSEIF radio6 EQ 'X'.
    CONCATENATE l_semester 'II' INTO l_semester
      SEPARATED BY space.
  ENDIF.
*--- Tahun
  CONCATENATE l_tahun sy-datum(4) INTO l_tahun
    SEPARATED BY space.

*--- output line
  WRITE: /l_start l_title.
  SKIP 1.
  WRITE: / l_plant,
         / l_alamat,
         / l_ort01.
  WRITE: /l_pos l_semester,
         /l_pos l_tahun.
ENDFORM.                    " f_hdr_line5

*---------------------------------------------------------------------*
*       FORM f_end_of_list1                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_end_of_list1.

  SKIP 1.
  PERFORM f_hdr_uline.
  PERFORM f_ftr_line1 USING ''.
  PERFORM f_hdr_uline.
  PERFORM f_ftr_line2 USING ''.
  PERFORM f_hdr_uline.
  PERFORM f_ftr_line3 USING ''.
ENDFORM.
