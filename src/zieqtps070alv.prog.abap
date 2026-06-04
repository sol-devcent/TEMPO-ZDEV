*&---------------------------------------------------------------------*
*&  Include           IEQTPS070ALV
*& ALV Output for RIEQS070 and RITPS070
*&---------------------------------------------------------------------*

*--- Data declaration
TYPE-POOLS: slis.

*--- types for output tables
TYPES: BEGIN OF gtype_object_head,
         tplnr       TYPE tplnr,
         equnr       TYPE equnr,
         ktext       TYPE ktx01,
         xaus        TYPE sauszt,
         xtbr        TYPE seqtbr,
         xmtbr       TYPE seqtbr,
       END OF gtype_object_head,

       BEGIN OF gtype_object_item,
         tplnr       TYPE tplnr,
         equnr       TYPE equnr,
         spmon       TYPE spmon,
         nbdeff      TYPE i,
         sttrhrs(12) TYPE p DECIMALS 3,
         xmttr       TYPE seqtbr,
         xmtbr       TYPE seqtbr,
       END OF gtype_object_item,

       BEGIN OF gtype_qmnum,
         qmnum       TYPE qmnum,
         ausvn       TYPE ausvn,
         auztv       TYPE auztv,
         ausbs       TYPE ausbs,
         auztb       TYPE auztb,
         sgauszt     TYPE sgauszt,
         color(4)    TYPE c,
       END OF gtype_qmnum,

       BEGIN OF gtype_stat,
         field(40)   TYPE c,
         value(20)   TYPE c,
       END OF gtype_stat.

TYPES : BEGIN OF ty_out,
          mark,
          tplnr       TYPE tplnr,
          equnr       TYPE equnr,
          pltxt       TYPE pltxt,
          ktext       TYPE ktx01,
          spmon       TYPE spmon,
          nbdeff      TYPE i,
          sttrhrs(12) TYPE p DECIMALS 3,
          xmttr       TYPE p DECIMALS 3,  "seqtbr,
          stbrhrs(12) TYPE p DECIMALS 3,
          xmtbr       TYPE p DECIMALS 3,  "seqtbr,
        END OF ty_out.

DATA: gt_object_head TYPE TABLE OF gtype_object_head,
      gt_object_item TYPE TABLE OF gtype_object_item,
      gt_qmnum       TYPE TABLE OF gtype_qmnum,
      gt_stat        TYPE TABLE OF gtype_stat,
      g_ktext(40)    TYPE c,
      g_date         LIKE sy-datum.

CONSTANTS: gc_head_tab TYPE slis_tabname VALUE 'GT_OBJECT_HEAD',
           gc_item_tab TYPE slis_tabname VALUE 'GT_OBJECT_ITEM',
           gc_noti_tab TYPE slis_tabname VALUE 'GT_QMNUM',
           gc_stat_tab TYPE slis_tabname VALUE 'GT_STAT',
           gc_x(1)     TYPE c VALUE 'X'.

DATA: gs_layout            TYPE lvc_s_layo,
      gt_alv_fieldcat      TYPE lvc_t_fcat,
      gt_alv_sort          TYPE lvc_t_sort,
      gt_out               TYPE STANDARD TABLE OF ty_out.

*--- FORMs

*&---------------------------------------------------------------------*
*&      Form  alv_main_output
*&---------------------------------------------------------------------*
*       Output of MAIN-ALV-List
*----------------------------------------------------------------------*
FORM alv_main_output .

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
        ls_keyinfo  TYPE slis_keyinfo_alv,
        ls_layout   TYPE slis_layout_alv,
        lt_sortinfo TYPE slis_t_sortinfo_alv,
        l_repid     LIKE sy-repid.

  l_repid = sy-repid.

  PERFORM alv_main_fieldcat_create USING lt_fieldcat.

  PERFORM alv_main_keyinfo USING ls_keyinfo.

  PERFORM alv_main_sort_create USING lt_sortinfo.

*--- create layout
  ls_layout-no_totalline   = gc_x.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK              = ' '
      i_callback_program             = l_repid
      i_callback_pf_status_set       = 'ALV_MAIN_PF_STATUS'
      i_callback_user_command        = 'ALV_MAIN_USER_COMMAND'
      is_layout                      = ls_layout
      it_fieldcat                    = lt_fieldcat
*     IT_EXCLUDING                   =
*     IT_SPECIAL_GROUPS              =
      it_sort                        = lt_sortinfo
*     IT_FILTER                      =
*     IS_SEL_HIDE                    =
*     I_SCREEN_START_COLUMN          = 0
*     I_SCREEN_START_LINE            = 0
*     I_SCREEN_END_COLUMN            = 0
*     I_SCREEN_END_LINE              = 0
*     I_DEFAULT                      = 'X'
      i_save                         = ' '
*     IS_VARIANT                     =
*     IT_EVENTS                      =
*     IT_EVENT_EXIT                  =
      i_tabname_header               = gc_head_tab
      i_tabname_item                 = gc_item_tab
*     I_STRUCTURE_NAME_HEADER        =
*     I_STRUCTURE_NAME_ITEM          =
      is_keyinfo                     = ls_keyinfo
*     IS_PRINT                       =
*     IS_REPREP_ID                   =
*     I_BYPASSING_BUFFER             =
*     I_BUFFER_ACTIVE                =
*     IR_SALV_HIERSEQ_ADAPTER        =
*     IT_EXCEPT_QINFO                =
*     I_SUPPRESS_EMPTY_DATA          = ABAP_FALSE
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER        =
*     ES_EXIT_CAUSED_BY_USER         =
    TABLES
      t_outtab_header                = gt_object_head
      t_outtab_item                  = gt_object_item
    EXCEPTIONS
      program_error                  = 1
      OTHERS                         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " alv_main_output

*&---------------------------------------------------------------------*
*&      Form  alv_main_fieldcat_create
*&---------------------------------------------------------------------*
*       Creates Fieldcatalog for Main-ALV
*----------------------------------------------------------------------*
*      <--ET_FIELDCAT  field catalog
*----------------------------------------------------------------------*
FORM alv_main_fieldcat_create
     USING et_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.

*--- Header Fields
  IF sy-repid = 'RIEQS070' OR
    sy-repid = 'ZRIEQS070'.
    ls_fieldcat-fieldname     = 'EQUNR'.
    ls_fieldcat-tabname       = gc_head_tab.
    ls_fieldcat-col_pos       = 1.
    ls_fieldcat-row_pos       = 1.
    ls_fieldcat-ref_tabname   = 'S070'.
    APPEND ls_fieldcat TO et_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname     = 'KTEXT'.
    ls_fieldcat-tabname       = gc_head_tab.
    ls_fieldcat-col_pos       = 2.
    ls_fieldcat-row_pos       = 1.
    ls_fieldcat-ref_fieldname = 'EQKTX'.
    ls_fieldcat-ref_tabname   = 'EQKT'.
    APPEND ls_fieldcat TO et_fieldcat.
  ENDIF.

  IF sy-repid = 'RITPS070' OR
    sy-repid = 'ZRITPS070'.
    ls_fieldcat-fieldname     = 'TPLNR'.
    ls_fieldcat-tabname       = gc_head_tab.
    ls_fieldcat-col_pos       = 1.
    ls_fieldcat-row_pos       = 1.
    ls_fieldcat-ref_tabname   = 'S070'.
    APPEND ls_fieldcat TO et_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname     = 'KTEXT'.
    ls_fieldcat-tabname       = gc_head_tab.
    ls_fieldcat-col_pos       = 2.
    ls_fieldcat-row_pos       = 1.
    ls_fieldcat-ref_fieldname = 'PLTXT'.
    ls_fieldcat-ref_tabname   = 'IFLOTX'.
    APPEND ls_fieldcat TO et_fieldcat.
  ENDIF.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'XAUS'.
  ls_fieldcat-tabname       = gc_head_tab.
  ls_fieldcat-col_pos       = 1.
  ls_fieldcat-row_pos       = 2.
  ls_fieldcat-outputlen     = 25.
  ls_fieldcat-decimals_out  = 2.
  ls_fieldcat-seltext_l     = text-012.
  ls_fieldcat-seltext_m     = text-012.
  ls_fieldcat-seltext_s     = text-012.
  ls_fieldcat-ref_fieldname = 'SAUSZT'.
  ls_fieldcat-ref_tabname   = 'S070'.
  APPEND ls_fieldcat TO et_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'XTBR'.
  ls_fieldcat-tabname       = gc_head_tab.
  ls_fieldcat-col_pos       = 2.
  ls_fieldcat-row_pos       = 2.
  ls_fieldcat-outputlen     = 25.
  ls_fieldcat-decimals_out  = 2.
  ls_fieldcat-seltext_l     = text-014.
  ls_fieldcat-seltext_m     = text-014.
  ls_fieldcat-seltext_s     = text-014.
  ls_fieldcat-ref_fieldname = 'SEQTBR'.
  ls_fieldcat-ref_tabname   = 'S070'.
  APPEND ls_fieldcat TO et_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'XMTBR'.
  ls_fieldcat-tabname       = gc_head_tab.
  ls_fieldcat-col_pos       = 3.
  ls_fieldcat-row_pos       = 2.
  ls_fieldcat-outputlen     = 30.
  ls_fieldcat-decimals_out  = 2.
  ls_fieldcat-seltext_l     = text-016.
  ls_fieldcat-seltext_m     = text-016.
  ls_fieldcat-seltext_s     = text-016.
  ls_fieldcat-ref_fieldname = 'SEQTBR'.
  ls_fieldcat-ref_tabname   = 'S070'.
  APPEND ls_fieldcat TO et_fieldcat.

*--- ITEM Fields
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'SPMON'.
  ls_fieldcat-tabname       = gc_item_tab.
  ls_fieldcat-col_pos       = 1.
  ls_fieldcat-row_pos       = 1.
  ls_fieldcat-seltext_l     = text-024.
  ls_fieldcat-seltext_m     = text-024.
  ls_fieldcat-seltext_s     = text-024.
  ls_fieldcat-ref_fieldname = 'SPMON'.
  ls_fieldcat-ref_tabname   = 'S070'.
  APPEND ls_fieldcat TO et_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'NBDEFF'.
  ls_fieldcat-tabname       = gc_item_tab.
  ls_fieldcat-col_pos       = 2.
  ls_fieldcat-row_pos       = 1.
  ls_fieldcat-do_sum        = gc_x.
  ls_fieldcat-seltext_l     = text-026.
  ls_fieldcat-seltext_m     = text-026.
  ls_fieldcat-seltext_s     = text-026.
  ls_fieldcat-datatype      = 'INT4'.
  ls_fieldcat-inttype       = 'I'.
  APPEND ls_fieldcat TO et_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'STTRHRS'.
  ls_fieldcat-tabname       = gc_item_tab.
  ls_fieldcat-col_pos       = 3.
  ls_fieldcat-row_pos       = 1.
  ls_fieldcat-outputlen     = 15.
  ls_fieldcat-decimals_out  = 2.
  ls_fieldcat-do_sum        = gc_x.
  ls_fieldcat-seltext_l     = text-028.
  ls_fieldcat-seltext_m     = text-028.
  ls_fieldcat-seltext_s     = text-028.
  ls_fieldcat-datatype      = 'QUAN'.
  ls_fieldcat-inttype       = 'P'.
  ls_fieldcat-intlen        = 12.
  ls_fieldcat-ddic_outputlen = 16.
  APPEND ls_fieldcat TO et_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'XMTTR'.
  ls_fieldcat-tabname       = gc_item_tab.
  ls_fieldcat-col_pos       = 4.
  ls_fieldcat-row_pos       = 1.
  ls_fieldcat-decimals_out  = 2.
  ls_fieldcat-seltext_l     = text-030.
  ls_fieldcat-seltext_m     = text-030.
  ls_fieldcat-seltext_s     = text-030.
  ls_fieldcat-ref_fieldname = 'SEQTBR'.
  ls_fieldcat-ref_tabname   = 'S070'.
  APPEND ls_fieldcat TO et_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'XMTBR'.
  ls_fieldcat-tabname       = gc_item_tab.
  ls_fieldcat-col_pos       = 5.
  ls_fieldcat-row_pos       = 1.
  ls_fieldcat-decimals_out  = 2.
  ls_fieldcat-seltext_l     = text-032.
  ls_fieldcat-seltext_m     = text-032.
  ls_fieldcat-seltext_s     = text-032.
  ls_fieldcat-ref_fieldname = 'SEQTBR'.
  ls_fieldcat-ref_tabname   = 'S070'.
  APPEND ls_fieldcat TO et_fieldcat.

ENDFORM.                    " alv_main_fieldcat_create

*&---------------------------------------------------------------------*
*&      Form  alv_main_keyinfo
*&---------------------------------------------------------------------*
*       Key information for main-alv
*----------------------------------------------------------------------*
*      <--ES_KEYINFO  key informtion
*----------------------------------------------------------------------*
FORM alv_main_keyinfo  USING es_keyinfo TYPE slis_keyinfo_alv.

  IF sy-repid = 'RIEQS070' OR
    sy-repid = 'ZRIEQS070'.
    es_keyinfo-header01 = 'EQUNR'.
    es_keyinfo-item01   = 'EQUNR'.
  ENDIF.

  IF sy-repid = 'RITPS070' OR
    sy-repid = 'ZRITPS070'.
    es_keyinfo-header01 = 'TPLNR'.
    es_keyinfo-item01   = 'TPLNR'.
  ENDIF.

ENDFORM.                    " alv_main_keyinfo

*&---------------------------------------------------------------------*
*&      Form  alv_main_sort_create
*&---------------------------------------------------------------------*
*       Create sortation for main-alv
*----------------------------------------------------------------------*
*      <--ET_SORT_CAT  Sort table
*----------------------------------------------------------------------*
FORM alv_main_sort_create  USING et_sortinfo TYPE slis_t_sortinfo_alv.

  DATA: ls_sortinfo TYPE slis_sortinfo_alv.

  IF sy-repid = 'RIEQS070' OR
    sy-repid = 'ZRIEQS070'.
    ls_sortinfo-fieldname = 'EQUNR'.
  ENDIF.

  IF sy-repid = 'RITPS070' OR
    sy-repid = 'ZRITPS070'.
    ls_sortinfo-fieldname = 'TPLNR'.
  ENDIF.

  ls_sortinfo-up     = gc_x.
  ls_sortinfo-subtot = gc_x.
  APPEND ls_sortinfo TO et_sortinfo.

ENDFORM.                    " alv_main_sort_create

*&---------------------------------------------------------------------*
*&      Form  alv_main_pf_status
*&---------------------------------------------------------------------*
*       SETS PF-STATUS for Main-alv
*----------------------------------------------------------------------*
*      -->IT_EXTAB   exclusion table
*----------------------------------------------------------------------*
FORM alv_main_pf_status USING it_extab TYPE slis_t_extab.   "#EC CALLED

  SET PF-STATUS 'MAIN'.

ENDFORM.                    " alv_main_pf_status

*&--------------------------------------------------------------------*
*&      Form  alv_main_user_command
*&--------------------------------------------------------------------*
*       User command handling in ALV Selfield is for selected row
*---------------------------------------------------------------------*
*      -->I_UCOMM     OK-code
*      <->XS_SELFIELD field information
*---------------------------------------------------------------------*
FORM alv_main_user_command USING i_ucomm     LIKE sy-ucomm  "#EC CALLED
                                 xs_selfield TYPE slis_selfield.

  DATA: l_equnr TYPE equnr,
        l_tplnr TYPE tplnr.

  FIELD-SYMBOLS: <ls_object_head> TYPE gtype_object_head,
                 <ls_object_item> TYPE gtype_object_item.

  CASE i_ucomm.
    WHEN '&IC1'.          "detail for period
      IF xs_selfield-tabname = gc_item_tab.
        READ TABLE gt_object_item ASSIGNING <ls_object_item>
                                  INDEX xs_selfield-tabindex.
        IF sy-subrc IS INITIAL.

          IF sy-repid = 'RIEQS070' OR
            sy-repid = 'ZRIEQS070'.
            READ TABLE lt_result INTO ls_result
                       WITH KEY equnr = <ls_object_item>-equnr
                                spmon = <ls_object_item>-spmon.
          ENDIF.
          IF sy-repid = 'RITPS070' OR
            sy-repid = 'ZRITPS070'.
            READ TABLE lt_result INTO ls_result
                       WITH KEY tplnr = <ls_object_item>-tplnr
                                spmon = <ls_object_item>-spmon.
          ENDIF.

          CHECK NOT ( ls_result-spmon IS INITIAL ).
          PERFORM einzel_meldung.
        ENDIF.
      ENDIF.

    WHEN 'S070'.          "update info structure
      IF xs_selfield-tabname = gc_head_tab.
        READ TABLE gt_object_head ASSIGNING <ls_object_head>
                                  INDEX xs_selfield-tabindex.
        IF sy-subrc IS INITIAL.
          l_equnr = <ls_object_head>-equnr.
          l_tplnr = <ls_object_head>-tplnr.
        ENDIF.
      ELSEIF xs_selfield-tabname = gc_item_tab.
        READ TABLE gt_object_item ASSIGNING <ls_object_item>
                                  INDEX xs_selfield-tabindex.
        IF sy-subrc IS INITIAL.
          l_equnr = <ls_object_item>-equnr.
          l_tplnr = <ls_object_item>-tplnr.
        ENDIF.
      ENDIF.

      CHECK NOT ( l_equnr IS INITIAL AND l_tplnr IS INITIAL ).
      IF sy-repid = 'RIEQS070' OR
        sy-repid = 'ZRIEQS070'.
        PERFORM confirm_step USING l_equnr x_answer.
      ENDIF.
      IF sy-repid = 'RITPS070' OR
        sy-repid = 'ZRITPS070'.
        PERFORM confirm_step USING l_tplnr x_answer.
      ENDIF.
      CHECK x_answer = yj.
      PERFORM s070_put USING l_equnr
                             l_tplnr
                             lt_result
                             lt_mciqmadd.
  ENDCASE.

ENDFORM.                    " alv_main_user_command

*&---------------------------------------------------------------------*
*&      Form  alv_noti_output
*&---------------------------------------------------------------------*
*       Output of Notification ALV
*----------------------------------------------------------------------*
FORM alv_noti_output .

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
        ls_layout   TYPE slis_layout_alv,
        lt_events   TYPE slis_t_event,
        l_repid     LIKE sy-repid.

  l_repid = sy-repid.

  PERFORM alv_noti_fieldcat_create USING lt_fieldcat.

  PERFORM alv_noti_events USING lt_events.

*--- create layout
  ls_layout-list_append    = 'Y'.
  ls_layout-info_fieldname = 'COLOR'.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK              = ' '
*     I_BYPASSING_BUFFER             =
*     I_BUFFER_ACTIVE                = ' '
      i_callback_program             = l_repid
      i_callback_pf_status_set       = 'ALV_NOTI_PF_STATUS'
      i_callback_user_command        = 'ALV_NOTI_USER_COMMAND'
*     I_STRUCTURE_NAME               =
      is_layout                      = ls_layout
      it_fieldcat                    = lt_fieldcat
*     IT_EXCLUDING                   =
*     IT_SPECIAL_GROUPS              =
*     IT_SORT                        =
*     IT_FILTER                      =
*     IS_SEL_HIDE                    =
*     I_DEFAULT                      = 'X'
      i_save                         = ' '
*     IS_VARIANT                     =
      it_events                      = lt_events
*     IT_EVENT_EXIT                  =
*     IS_PRINT                       =
*     IS_REPREP_ID                   =
*     I_SCREEN_START_COLUMN          = 0
*     I_SCREEN_START_LINE            = 0
*     I_SCREEN_END_COLUMN            = 0
*     I_SCREEN_END_LINE              = 0
*     IR_SALV_LIST_ADAPTER           =
*     IT_EXCEPT_QINFO                =
*     I_SUPPRESS_EMPTY_DATA          = ABAP_FALSE
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER        =
*     ES_EXIT_CAUSED_BY_USER         =
    TABLES
      t_outtab                       = gt_qmnum
    EXCEPTIONS
      program_error                  = 1
      OTHERS                         = 2
            .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " alv_noti_output

*&---------------------------------------------------------------------*
*&      Form  alv_noti_fieldcat_create
*&---------------------------------------------------------------------*
*       Creates Fieldcatalog for Notification-ALV
*----------------------------------------------------------------------*
*      <--ET_FIELDCAT  field catalog
*----------------------------------------------------------------------*
FORM alv_noti_fieldcat_create
     USING et_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.

  ls_fieldcat-fieldname   = 'QMNUM'.
  ls_fieldcat-tabname     = gc_noti_tab.
  ls_fieldcat-col_pos     = 1.
  ls_fieldcat-ref_tabname = 'QMIH'.
  APPEND ls_fieldcat TO et_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'AUSVN'.
  ls_fieldcat-tabname     = gc_noti_tab.
  ls_fieldcat-col_pos     = 2.
  ls_fieldcat-ref_tabname = 'QMIH'.
  APPEND ls_fieldcat TO et_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'AUZTV'.
  ls_fieldcat-tabname     = gc_noti_tab.
  ls_fieldcat-col_pos     = 3.
  ls_fieldcat-ref_tabname = 'QMIH'.
  APPEND ls_fieldcat TO et_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'AUSBS'.
  ls_fieldcat-tabname     = gc_noti_tab.
  ls_fieldcat-col_pos     = 4.
  ls_fieldcat-ref_tabname = 'QMIH'.
  APPEND ls_fieldcat TO et_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'AUZTB'.
  ls_fieldcat-tabname     = gc_noti_tab.
  ls_fieldcat-col_pos     = 5.
  ls_fieldcat-ref_tabname = 'QMIH'.
  APPEND ls_fieldcat TO et_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'SGAUSZT'.
  ls_fieldcat-tabname     = gc_noti_tab.
  ls_fieldcat-col_pos     = 6.
  ls_fieldcat-decimals_out = 2.
  ls_fieldcat-seltext_l   = text-066.
  ls_fieldcat-seltext_m   = text-066.
  ls_fieldcat-seltext_s   = text-066.
  ls_fieldcat-ref_tabname = 'MCIPM'.
  APPEND ls_fieldcat TO et_fieldcat.

ENDFORM.                    " alv_noti_fieldcat_create

*&---------------------------------------------------------------------*
*&      Form  alv_noti_events
*&---------------------------------------------------------------------*
*       Fill event table for notification ALV
*----------------------------------------------------------------------*
*      -->XT_EVENTS  event table
*----------------------------------------------------------------------*
FORM alv_noti_events  USING xt_events TYPE slis_t_event.

  FIELD-SYMBOLS: <ls_event> TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type     = 0
    IMPORTING
      et_events       = xt_events
    EXCEPTIONS
      list_type_wrong = 1
      OTHERS          = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  READ TABLE xt_events ASSIGNING <ls_event>
                       WITH KEY name = slis_ev_top_of_page.
  IF sy-subrc IS INITIAL.
    <ls_event>-form = 'ALV_NOTI_TOP_OF_PAGE'.
  ENDIF.

  READ TABLE xt_events ASSIGNING <ls_event>
                       WITH KEY name = slis_ev_end_of_list.
  IF sy-subrc IS INITIAL.
    <ls_event>-form = 'ALV_NOTI_END_OF_LIST'.
  ENDIF.

ENDFORM.                    " alv_noti_events

*&---------------------------------------------------------------------*
*&      Form  alv_noti_pf_status
*&---------------------------------------------------------------------*
*       SETS PF-STATUS for Notification-alv
*----------------------------------------------------------------------*
*      -->IT_EXTAB   exclusion table
*----------------------------------------------------------------------*
FORM alv_noti_pf_status USING it_extab TYPE slis_t_extab.   "#EC CALLED

  SET PF-STATUS 'MELD'.

ENDFORM.                    " alv_noti_pf_status

*&--------------------------------------------------------------------*
*&      Form  alv_noti_user_command
*&--------------------------------------------------------------------*
*       User command handling in ALV Selfield is for selected row
*---------------------------------------------------------------------*
*      -->I_UCOMM     OK-code
*      <->XS_SELFIELD field information
*---------------------------------------------------------------------*
FORM alv_noti_user_command USING i_ucomm     LIKE sy-ucomm  "#EC CALLED
                                 xs_selfield TYPE slis_selfield.

  FIELD-SYMBOLS: <ls_qmnum> TYPE gtype_qmnum.

  CHECK xs_selfield-tabname = gc_noti_tab.

  CASE i_ucomm.
    WHEN 'MELD' OR '&IC1'.   "display notification
      READ TABLE gt_qmnum ASSIGNING <ls_qmnum>
                          INDEX xs_selfield-tabindex.
      IF sy-subrc IS INITIAL.
        ok_memory = 'AFDT'.
        EXPORT ok_memory TO MEMORY ID ypm.
        SET PARAMETER ID 'IQM' FIELD <ls_qmnum>-qmnum.
        CALL TRANSACTION  'IQS3' AND SKIP FIRST SCREEN.
      ENDIF.
  ENDCASE.

ENDFORM.                    " alv_noti_user_command

*&---------------------------------------------------------------------*
*&      Form  alv_noti_top_of_page
*&---------------------------------------------------------------------*
*       SETS PF-STATUS for Notification-alv
*----------------------------------------------------------------------*
FORM alv_noti_top_of_page.                                  "#EC CALLED

  DATA: lt_listheader TYPE  slis_t_listheader,
        ls_listheader TYPE  slis_listheader,
        lt_tline      TYPE TABLE OF tline,
        ls_tline      TYPE tline.

*--- reference object -------------------------------------------------*
  IF sy-repid = 'RIEQS070' OR
   sy-repid = 'ZRIEQS070'.
    ls_listheader-typ  = 'S'.
    ls_listheader-key  = text-020.
    WRITE ls_result-equnr TO ls_listheader-info.
    APPEND ls_listheader TO lt_listheader.
  ENDIF.

  IF sy-repid = 'RITPS070' OR
    sy-repid = 'ZRITPS070'.
    ls_listheader-typ  = 'S'.
    ls_listheader-key  = text-022.
    WRITE ls_result-tplnr TO ls_listheader-info.
    APPEND ls_listheader TO lt_listheader.
  ENDIF.

  CLEAR ls_listheader.
  ls_listheader-typ  = 'S'.
  ls_listheader-key  = text-100.
  ls_listheader-info = g_ktext.
  APPEND ls_listheader TO lt_listheader.

*--- startup date -----------------------------------------------------*
  CLEAR ls_listheader.
  IF g_date IS NOT INITIAL.
    ls_listheader-typ  = 'S'.
    ls_listheader-key  = text-038.
    WRITE g_date TO ls_listheader-info.
    APPEND ls_listheader TO lt_listheader.
  ELSE.
    ls_tline-tdline = text-082.
    APPEND ls_tline TO lt_tline.
    ls_tline-tdline = text-084.
    APPEND ls_tline TO lt_tline.

    CALL FUNCTION 'FORMAT_TEXTLINES'
      EXPORTING
*        CURSOR_COLUMN           = 0
*        CURSOR_LINE             = 0
*        ENDLINE                 = 99999
        formatwidth             = 60
        linewidth               = 132
        startline               = 1
*        LANGUAGE                = SY-LANGU
*      IMPORTING
*        NEW_CURSOR_COLUMN       =
*        NEW_CURSOR_LINE         =
      TABLES
        lines                   = lt_tline
      EXCEPTIONS
        bound_error             = 1
        OTHERS                  = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    ls_listheader-key  = text-038.
    LOOP AT lt_tline INTO ls_tline.
      ls_listheader-typ  = 'S'.
      ls_listheader-info = ls_tline-tdline.
      APPEND ls_listheader TO lt_listheader.
      CLEAR ls_listheader.
    ENDLOOP.
  ENDIF.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_listheader.

ENDFORM.                    " alv_noti_top_of_page

*&---------------------------------------------------------------------*
*&      Form  alv_noti_end_of_list
*&---------------------------------------------------------------------*
*       SETS PF-STATUS for Notification-alv
*----------------------------------------------------------------------*
*      -->IT_EXTAB   exclusion table
*----------------------------------------------------------------------*
FORM alv_noti_end_of_list.                                  "#EC CALLED

  PERFORM alv_stat_output.

ENDFORM.                    " alv_noti_end_of_list

*&---------------------------------------------------------------------*
*&      Form  alv_stat_output
*&---------------------------------------------------------------------*
*       Output of statistic- ALV
*----------------------------------------------------------------------*
FORM alv_stat_output .

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
        ls_layout   TYPE slis_layout_alv,
        lt_events   TYPE slis_t_event,
        l_repid     LIKE sy-repid.

  l_repid = sy-repid.

  PERFORM alv_stat_fieldcat_create USING lt_fieldcat.

  PERFORM alv_stat_events USING lt_events.

*--- create layout
  ls_layout-list_append       = gc_x.
  ls_layout-colwidth_optimize = gc_x.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK              = ' '
*     I_BYPASSING_BUFFER             =
*     I_BUFFER_ACTIVE                = ' '
      i_callback_program             = l_repid
*     I_CALLBACK_PF_STATUS_SET       = 'ALV_STAT_PF_STATUS'
*     I_CALLBACK_USER_COMMAND        = 'ALV_STAT_USER_COMMAND'
*     I_STRUCTURE_NAME               =
      is_layout                      = ls_layout
      it_fieldcat                    = lt_fieldcat
*     IT_EXCLUDING                   =
*     IT_SPECIAL_GROUPS              =
*     IT_SORT                        =
*     IT_FILTER                      =
*     IS_SEL_HIDE                    =
*     I_DEFAULT                      = 'X'
      i_save                         = ' '
*     IS_VARIANT                     =
      it_events                      = lt_events
*     IT_EVENT_EXIT                  =
*     IS_PRINT                       =
*     IS_REPREP_ID                   =
*     I_SCREEN_START_COLUMN          = 0
*     I_SCREEN_START_LINE            = 0
*     I_SCREEN_END_COLUMN            = 0
*     I_SCREEN_END_LINE              = 0
*     IR_SALV_LIST_ADAPTER           =
*     IT_EXCEPT_QINFO                =
*     I_SUPPRESS_EMPTY_DATA          = ABAP_FALSE
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER        =
*     ES_EXIT_CAUSED_BY_USER         =
    TABLES
      t_outtab                       = gt_stat
    EXCEPTIONS
      program_error                  = 1
      OTHERS                         = 2
            .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " alv_stat_output

*&---------------------------------------------------------------------*
*&      Form  alv_stat_fieldcat_create
*&---------------------------------------------------------------------*
*       Creates Fieldcatalog for Status-ALV
*----------------------------------------------------------------------*
*      <--ET_FIELDCAT  field catalog
*----------------------------------------------------------------------*
FORM alv_stat_fieldcat_create
     USING et_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.

  ls_fieldcat-fieldname     = 'FIELD'.
  ls_fieldcat-tabname       = gc_stat_tab.
  ls_fieldcat-col_pos       = 1.
  ls_fieldcat-do_sum        = gc_x.
  ls_fieldcat-seltext_l     = text-100.
  ls_fieldcat-seltext_m     = text-100.
  ls_fieldcat-seltext_s     = text-100.
  ls_fieldcat-datatype      = 'CHAR'.
  ls_fieldcat-inttype       = 'C'.
  ls_fieldcat-intlen        = 40.
  APPEND ls_fieldcat TO et_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'VALUE'.
  ls_fieldcat-tabname       = gc_stat_tab.
  ls_fieldcat-col_pos       = 2.
  ls_fieldcat-do_sum        = gc_x.
  ls_fieldcat-seltext_l     = text-101.
  ls_fieldcat-seltext_m     = text-101.
  ls_fieldcat-seltext_s     = text-101.
  ls_fieldcat-datatype      = 'CHAR'.
  ls_fieldcat-inttype       = 'C'.
  ls_fieldcat-intlen        = 20.
  ls_fieldcat-just          = 'R'.
  APPEND ls_fieldcat TO et_fieldcat.

ENDFORM.                    " alv_stat_fieldcat_create

*&---------------------------------------------------------------------*
*&      Form  alv_stat_events
*&---------------------------------------------------------------------*
*       Fill event table for notification ALV
*----------------------------------------------------------------------*
*      -->XT_EVENTS  event table
*----------------------------------------------------------------------*
FORM alv_stat_events  USING xt_events TYPE slis_t_event.

  FIELD-SYMBOLS: <ls_event> TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type     = 0
    IMPORTING
      et_events       = xt_events
    EXCEPTIONS
      list_type_wrong = 1
      OTHERS          = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  READ TABLE xt_events ASSIGNING <ls_event>
                       WITH KEY name = slis_ev_top_of_page.
  IF sy-subrc IS INITIAL.
    <ls_event>-form = 'ALV_STAT_TOP_OF_PAGE'.
  ENDIF.

ENDFORM.                    " alv_stat_events

*&---------------------------------------------------------------------*
*&      Form  alv_stat_top_of_page
*&---------------------------------------------------------------------*
*       SETS PF-STATUS for Notification-alv
*----------------------------------------------------------------------*
FORM alv_stat_top_of_page.                                  "#EC CALLED

  DATA: lt_listheader TYPE  slis_t_listheader,
        ls_listheader TYPE  slis_listheader.

  ls_listheader-typ  = 'H'.
  ls_listheader-info = text-042.
  APPEND ls_listheader TO lt_listheader.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_listheader.

ENDFORM.                    " alv_stat_top_of_page

*&---------------------------------------------------------------------*
*&      Form  ALV_OUTPUT
*&---------------------------------------------------------------------*
FORM alv_output .
  DATA : ls_item    LIKE LINE OF gt_object_item,
         ls_out     LIKE LINE OF gt_out,
         ls_result  LIKE LINE OF lt_result.

  DATA : ls_eqkt    TYPE eqkt,
         ls_equi    TYPE equi,
         ls_iflo    TYPE iflo.

  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat.
  PERFORM f_build_layout.
  PERFORM f_build_sortfield.

  LOOP AT gt_object_item INTO ls_item.
    MOVE-CORRESPONDING ls_item TO ls_out.

    CLEAR ls_result.
    CASE sy-repid.
      WHEN 'ZRIEQS070'.
        READ TABLE lt_result INTO ls_result
                             WITH KEY equnr = ls_out-equnr
                                      spmon = ls_out-spmon.

        CALL FUNCTION 'EQUIPMENT_READ_DISPLAY'
          EXPORTING
            reading_date = sy-datum
            equi_no      = ls_out-equnr
            hist         = 'X'
          IMPORTING
            eqkt         = ls_eqkt
            equi         = ls_equi.

        ls_out-ktext = ls_eqkt-eqktx.
      WHEN 'ZRITPS070'.
        READ TABLE lt_result INTO ls_result
                             WITH KEY tplnr = ls_out-tplnr
                                      spmon = ls_out-spmon.

        CALL FUNCTION 'FUNC_LOCATION_READ'
          EXPORTING
            spras   = sy-langu
            tplnr   = ls_out-tplnr
          IMPORTING
            pltxt   = ls_out-pltxt
            iflo_wa = ls_iflo.

    ENDCASE.
    ls_out-stbrhrs  = ls_result-stbrhrs.
    APPEND ls_out TO gt_out.
    CLEAR ls_out.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      is_layout_lvc            = gs_layout
      it_fieldcat_lvc          = gt_alv_fieldcat[]
      it_sort_lvc              = gt_alv_sort[]
      i_default                = 'X'
      i_save                   = 'A'
    TABLES
      t_outtab                 = gt_out
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    " ALV_OUTPUT

*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS
*---------------------------------------------------------------------*
FORM f_set_pf_status USING    rt_extab TYPE slis_t_extab.
  DATA fcode  TYPE TABLE OF sy-ucomm.

  sy-lsind = 0.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING     fu_ucomm LIKE sy-ucomm
                              fu_selfield TYPE slis_selfield.

ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_ALV_DATA
*&---------------------------------------------------------------------*
FORM f_clear_alv_data .
  CLEAR : gs_layout, gt_alv_fieldcat[], gt_alv_sort[], gt_out[].
ENDFORM.                    " F_CLEAR_ALV_DATA

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_build_fieldcat .
  DATA : lt_dyn_table  TYPE REF TO data,
         lr_tabdescr   TYPE REF TO cl_abap_structdescr,
         lt_dfies      TYPE ddfields,
         ls_dfies      TYPE dfies,
         ls_fieldcat   TYPE lvc_s_fcat.

  CLEAR : gt_alv_fieldcat[].
  CREATE DATA lt_dyn_table LIKE LINE OF gt_out.
  lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lt_dyn_table ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ).
  LOOP AT lt_dfies INTO ls_dfies.
    CLEAR ls_fieldcat.
    MOVE-CORRESPONDING ls_dfies TO ls_fieldcat.
    CASE ls_dfies-fieldname.
      WHEN 'MARK'.
        CONTINUE.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' 'X' '' '' '' '' 'X' '' 'X' 'X' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'ICON'.
        CONTINUE.
      WHEN 'TPLNR'.
        IF sy-repid = 'ZRIEQS070'.
          CONTINUE.
        ENDIF.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '20' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'PLTXT'.
        IF sy-repid = 'ZRIEQS070'.
          CONTINUE.
        ENDIF.
      WHEN 'EQUNR'.
        IF sy-repid = 'ZRITPS070'.
          CONTINUE.
        ENDIF.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'KTEXT'.
        IF sy-repid = 'ZRITPS070'.
          CONTINUE.
        ENDIF.
      WHEN 'MENGE'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' 'MEINS' '' '' '' '' '' '' '' '' '' '' 'X' '' ''
        CHANGING ls_fieldcat.
      WHEN 'DMBTR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' 'X' '' ''
        CHANGING ls_fieldcat.
      WHEN 'SPMON'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' text-024 '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'NBDEFF'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' text-026 '' '' '' '' '' '' '' '' '' '' ''
        CHANGING ls_fieldcat.
      WHEN 'STTRHRS'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' text-028 '15' '' '' '' '' '' '' '' '' '' '2'
        CHANGING ls_fieldcat.
      WHEN 'XMTTR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' text-030 '' '' '' '' '' '' '' '' '' '' '2'
        CHANGING ls_fieldcat.
      WHEN 'STBRHRS'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' text-014 '' '' '' '' '' '' '' '' '' '' '2'
        CHANGING ls_fieldcat.
      WHEN 'XMTBR'.
        PERFORM f_change_dyn_fieldcat USING :
        '' '' '' '' '' text-032 '' '' '' '' '' '' '' '' '' '' '2'
        CHANGING ls_fieldcat.
    ENDCASE.
    APPEND ls_fieldcat TO gt_alv_fieldcat.
    CLEAR ls_fieldcat.
  ENDLOOP.
ENDFORM.                    " F_BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout .
  gs_layout-zebra              = 'X'.
*  gs_layout-cwidth_opt         = 'X'.
*  gs_layout-col_opt            = 'X'.
  gs_layout-sel_mode           = 'B'.
  gs_layout-box_fname          = 'MARK'.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORTFIELD
*&---------------------------------------------------------------------*
FORM f_build_sortfield .
  DATA : ls_sort       TYPE lvc_s_sort.



  CLEAR ls_sort.
  CASE sy-repid.
    WHEN 'ZRIEQS070'.
      ls_sort-spos = '1'.
      ls_sort-fieldname = 'EQUNR'.
    WHEN 'ZRITPS070'.
      ls_sort-spos = '1'.
      ls_sort-fieldname = 'TPLNR'.
  ENDCASE.
  APPEND ls_sort TO gt_alv_sort.
ENDFORM.                    " F_BUILD_SORTFIELD

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_DYN_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_change_dyn_fieldcat  USING    fu_currency fu_cfieldname fu_quantity
                                     fu_qfieldname fu_checkbox fu_coltext
                                     fu_outputlen fu_inttype fu_no_out fu_edit
                                     fu_tech fu_key fu_fix fu_icon fu_sum
                                     fu_nosum fu_decout
                            CHANGING fs_dyn_fcat  TYPE lvc_s_fcat.

  IF fu_coltext IS NOT INITIAL.
    PERFORM f_isi_judul USING fu_coltext '' '' ''
                        CHANGING fs_dyn_fcat-reptext fs_dyn_fcat-scrtext_l
                                 fs_dyn_fcat-scrtext_m fs_dyn_fcat-scrtext_s.
  ENDIF.

  PERFORM f_move_fieldcat USING fu_currency
                          CHANGING fs_dyn_fcat-currency.
  PERFORM f_move_fieldcat USING fu_cfieldname
                          CHANGING fs_dyn_fcat-cfieldname.
  PERFORM f_move_fieldcat USING fu_quantity
                          CHANGING fs_dyn_fcat-quantity.
  PERFORM f_move_fieldcat USING fu_qfieldname
                          CHANGING fs_dyn_fcat-qfieldname.
  PERFORM f_move_fieldcat USING fu_checkbox
                          CHANGING fs_dyn_fcat-checkbox.
  PERFORM f_move_fieldcat USING fu_edit
                          CHANGING fs_dyn_fcat-edit.
  PERFORM f_move_fieldcat USING fu_outputlen
                          CHANGING fs_dyn_fcat-outputlen.
  PERFORM f_move_fieldcat USING fu_inttype
                          CHANGING fs_dyn_fcat-inttype.
  PERFORM f_move_fieldcat USING fu_no_out
                          CHANGING fs_dyn_fcat-no_out.
  PERFORM f_move_fieldcat USING fu_tech
                          CHANGING fs_dyn_fcat-tech.
  PERFORM f_move_fieldcat USING fu_key
                          CHANGING fs_dyn_fcat-key.
  PERFORM f_move_fieldcat USING fu_fix
                          CHANGING fs_dyn_fcat-fix_column.
  PERFORM f_move_fieldcat USING fu_icon
                          CHANGING fs_dyn_fcat-icon.
  PERFORM f_move_fieldcat USING fu_sum
                          CHANGING fs_dyn_fcat-do_sum.
  PERFORM f_move_fieldcat USING fu_nosum
                          CHANGING fs_dyn_fcat-no_sum.
  PERFORM f_move_fieldcat USING fu_decout
                          CHANGING fs_dyn_fcat-decimals_o.
ENDFORM.                    " F_CHANGE_DYN_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_ISI_JUDUL
*&---------------------------------------------------------------------*
FORM f_isi_judul  USING    fu_coltext fu_l fu_m fu_s
                  CHANGING fc_reptext fc_scrtext_l fc_scrtext_m fc_scrtext_s.

  fc_reptext    = fu_coltext.
  fc_scrtext_l  = fu_coltext.
  fc_scrtext_m  = fu_coltext.
  fc_scrtext_s  = fu_coltext.
ENDFORM.                    " F_ISI_JUDUL

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_move_fieldcat  USING    fu_value
                      CHANGING fc_value.
  IF fu_value IS NOT INITIAL.
    fc_value = fu_value.
  ENDIF.
ENDFORM.                    " F_MOVE_FIELDCAT
