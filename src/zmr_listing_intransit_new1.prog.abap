************************************************************************
*                                                                      *
*  PROGRAM NAME  :  ZMR_LISTING_INTRANSIT_NEW                          *
*  PROGRAM DESC  :  Listing Intransit                                  *
*  CREATED BY    :  BUDI PRAMONO                                       *
*  CREATED ON    :  20/01/2004 (DMY)                                   *
*  VERSION       :  4.6C                                               *
*                                                                      *
************************************************************************
*                                                                      *
*  MODIFICATION LOG :                                                  *
*                                                                      *
*  DATE        PROGRAMMER        CORRECTION  DESCRIPTION
*
*  ----------  ---------------  ----------  -------------------------  *
*  DD/MM/YYYY  XXXXXXXXXXXXXXX  XXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXX  *
*                                                                      *
************************************************************************
REPORT zmr_listing_intransit_new1 MESSAGE-ID zm
                                 LINE-SIZE 200
                                 LINE-COUNT 65
                                 NO STANDARD PAGE HEADING.

INCLUDE zmr_listing_intransit_new1top.

*---------------------------------------------------------------------*
* DEFINITION OF PARAMETER & SELECTION                                 *
*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS: p_bukrs LIKE t001-bukrs OBLIGATORY DEFAULT '8020',
            p_werks LIKE t001w-werks OBLIGATORY MEMORY ID wrk.
*              P_MJAHR LIKE MSEG-MJAHR OBLIGATORY,
*              P_BWART LIKE MSEG-BWART OBLIGATORY.
SELECT-OPTIONS: p_bwart FOR mseg-bwart OBLIGATORY DEFAULT '303'
                                       NO INTERVALS,
                p_lgort FOR mseg-lgort,
*                  P_KUNNR FOR MSEG-KUNNR,
                p_budat FOR mkpf-budat OBLIGATORY DEFAULT sy-datum MODIF ID bud,
                p_bldat FOR mkpf-bldat,
*                  P_CPUDT FOR MKPF-CPUDT,
                p_matnr FOR mseg-matnr.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE text-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio1 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(30) text-003 FOR FIELD p_radio1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio2 RADIOBUTTON GROUP grp1 DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(30) text-004 FOR FIELD p_radio2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(30) text-005 FOR FIELD p_radio3.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block2.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK c WITH FRAME TITLE text-006.
PARAMETERS : pa_vari TYPE slis_vari.
SELECTION-SCREEN END OF BLOCK c.

*
* VALIDATE FOR SELECTION
*------------------------
AT SELECTION-SCREEN ON p_bukrs.
**** Supaya bisa digunakan untuk semua Company Code
*  IF P_BUKRS = '8020' OR P_BUKRS = '8030'.
*  ELSE.
*    MESSAGE E000(ZM) WITH 'Only for Company Code "8020" "8030"'.
*  ENDIF.
AT SELECTION-SCREEN ON p_werks.
  AUTHORITY-CHECK OBJECT 'M_MSEG_WWA'
      ID 'ACTVT' FIELD '03'
      ID 'WERKS' FIELD p_werks.
  IF sy-subrc NE 0.
    MESSAGE e002(zz) WITH 'You are not authorized with Plant'
     p_werks.
  ENDIF.
**** Supaya bisa digunakan untuk semua Plant
*  IF P_BUKRS = '8020'.
*    IF P_WERKS NP '02*'.
*      MESSAGE E000(ZM) WITH 'Plant Must be entry "02xx"'.
*    ENDIF.
*  ELSE.
*    IF P_WERKS NP '03*'.
*      MESSAGE E000(ZM) WITH 'Plant Must be entry "03xx"'.
*    ENDIF.
*  ENDIF.
AT SELECTION-SCREEN ON p_bwart.
  LOOP AT p_bwart.
    IF p_bwart-low NE '303' AND
       p_bwart-low NE '641' AND
       p_bwart-low NE '313' AND
       p_bwart-low NE '351' AND
       p_bwart-low NE '907'.
      MESSAGE e000(zm) WITH 'Only for Movement Type "303" "641" "313" "351""907"'.
    ENDIF.
  ENDLOOP.
*  Select single * from zplbc
*    where werks = p_werks and live = 'X'.
*  if sy-subrc ne 0.
*      MESSAGE E000(ZM) WITH 'Only For SAP Branch'.
*  endif.
*AT SELECTION-SCREEN ON P_BWART.
*  IF P_BWART-LOW = '303' OR P_BWART-LOW = '641'.
*  ELSE.
*    MESSAGE E000(ZM) WITH 'Only for Movement type "303" "641"'.
*  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_vari.
  PERFORM f4_for_variant.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'XXX'.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_validate_screen_1000.
    WHEN space.
      PERFORM f_validate_screen_1000.
  ENDCASE.

*---------------------------------------------------------------------*
* PROGRAM                                                             *
*---------------------------------------------------------------------*
INITIALIZATION.
  CLEAR : itab.
  REFRESH : itab.
  PERFORM variant_init.

* Get default variant
  er_variant = e_variant.
  e_save = 'A'.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = e_save
    CHANGING
      cs_variant = er_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    pa_vari = er_variant-variant.
  ENDIF.

START-OF-SELECTION.
  PERFORM f_get_data.
  PERFORM f_process_data.
  DESCRIBE TABLE itab LINES v_line.
  MESSAGE s000(zm) WITH v_line 'Record Selected'.
  PERFORM append_structure_alv.
  PERFORM eventtab_build USING evtab[].

END-OF-SELECTION.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = 'ZMR_LISTING_INTRANSIT_NEW1'
      i_callback_user_command = e_user_command
      i_background_id         = 'ALV_BACKGROUND'
      is_variant              = disvariant
      it_fieldcat             = fieldcat[]
      it_events               = evtab[]
      i_save                  = 'A'
    IMPORTING
      e_exit_caused_by_caller = g_exit_caused_by_caller
      es_exit_caused_by_user  = gs_exit_caused_by_user
    TABLES
      t_outtab                = itab
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  INCLUDE zmr_listing_intransit_new1f01.
