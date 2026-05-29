*----------------------------------------------------------------------*
*    Print of pickinglist for one single delivery note                 *
*----------------------------------------------------------------------*
REPORT rvadek01 LINE-COUNT 100 MESSAGE-ID vn.

TABLES: vbco3,                         "Communicationarea for view
        vblkk,                         "Headerview
        vblkp,                         "Itemview
        ltak,                          "Transportauftrag
        adrs,                          "Communicationarea for Address
        riserls,                       "Serialnumbers
        komser,                        "Communicationarea Serialnumbers
        tvst, tvstt,                   "Shipping point
        vbkok, vbpok.

*** Begin CR KMM project
TABLES: kna1, zaccdtm.
*** End CR KMM Project

* Includes
INCLUDE rvadtabl.

TYPES: BEGIN OF ty_header.
        INCLUDE STRUCTURE zmpickreq.
TYPES: END OF ty_header.

DATA: wa_header TYPE ty_header.

DATA: BEGIN OF gt_detail OCCURS 0.
        INCLUDE STRUCTURE zmpickreq.
DATA: END OF gt_detail.

DATA: gt_nast LIKE nast OCCURS 0 WITH HEADER LINE.

DATA: gt_mara TYPE STANDARD TABLE OF mara INITIAL SIZE 0.

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DATA: retcode     LIKE sy-subrc,       "Returncode
      xvbeln      LIKE likp-vbeln,
      xkomau      LIKE likp-vbeln,
      xscreen(1)  TYPE c.              "Output on printer or screen

DATA: BEGIN OF tvblkp OCCURS 0.        "Internal table for items
        INCLUDE STRUCTURE vblkp.
DATA: END OF tvblkp.

DATA: BEGIN OF tsernr OCCURS 0.        "Internal table for serialnumbers
        INCLUDE STRUCTURE riserls.
DATA: END OF tsernr.

DATA: BEGIN OF tsernr_print OCCURS 0.
        INCLUDE STRUCTURE komser.
DATA: END   OF tsernr_print.

DATA:  BEGIN OF tltap OCCURS 50.       "TA-Positionen
        INCLUDE STRUCTURE ltap.
        INCLUDE STRUCTURE ltap1.
DATA:  END OF tltap.

DATA: BEGIN OF svblkp.
        INCLUDE STRUCTURE vblkp.
DATA: END OF svblkp.

DATA : va_vfdat LIKE mch1-vfdat,
       va_komng LIKE vblkp-komng,
       va_bezei LIKE tprit-bezei,
       va_vgpos LIKE vblkp-vgpos.

** Add by Budi 07/06/2007
** Req. by hgunawan
DATA : va_bnddt LIKE vbak-bnddt,
       va_vgbel LIKE lips-vgbel,
       va_name  LIKE thead-tdname,
       va_sotext1(50),
       va_sotext2(50),
       va_sotext3(50),
       va_lines LIKE tline OCCURS 0 WITH HEADER LINE.
** Endadd

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

INCLUDE vblpdata.
INCLUDE vbfadata.
INCLUDE vbukdata.
INCLUDE vbupdata.
INCLUDE vbbddata.
INCLUDE vbpadata.
INCLUDE sadrdata.

INCLUDE zabp_pparameter.
INCLUDE zabp_smartform.
INCLUDE zabp_frm.

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

*---------------------------------------------------------------------*
*       FORM ENTRY                                                    *
*---------------------------------------------------------------------*
*       Steuerung des Drucks                                          *
*---------------------------------------------------------------------*
FORM entry USING return_code us_screen.

  CLEAR retcode.
  xscreen = us_screen.
  PERFORM processing USING us_screen.
  IF retcode NE 0.
    return_code = 1.
* else.                                            " DEL_HP_312234
* Kommimengen an Lieferungen zurückgeben, aber nicht bei Druckansicht
*   if xscreen = ' '.
*      perform delivery_update.
*      return_code = 0.                            "<<< delete HP_145990
*   endif.
*   return_code = 0.                               "<<< insert HP_145990
* endif.
  ELSE.                                            " INS_HP_312234
    return_code = 0.
  ENDIF.

ENDFORM.                    "entry

*---------------------------------------------------------------------*
*       FORM ENTRY                                                    *
*---------------------------------------------------------------------*
*       Steuerung des Drucks                                          *
*---------------------------------------------------------------------*
FORM zentry USING return_code us_screen.

  CLEAR retcode.
  xscreen = us_screen.

  IF NOT tnapr-sform IS INITIAL.
    p_tdform   = tnapr-sform.
  ELSEIF NOT tnapr-fonam IS INITIAL.
    p_tdform   = tnapr-fonam.
  ENDIF.

  CLEAR: return_code.

  p_disp = xscreen = us_screen.
  p_dest = nast-ldest.

  " __* Reprint
  SELECT *
    FROM nast
    INTO CORRESPONDING FIELDS OF TABLE gt_nast
    WHERE kappl EQ nast-kappl
      AND objky EQ nast-objky
      AND kschl EQ nast-kschl.

  PERFORM processing_new.

  IF retcode NE 0.
    return_code = 1.
  ELSE.                                            " INS_HP_312234
    return_code = 0.
  ENDIF.

ENDFORM.                    "zentry

*---------------------------------------------------------------------*
*       FORM ENTRY                                                    *
*---------------------------------------------------------------------*
*       Steuerung des Drucks                                          *
*---------------------------------------------------------------------*
FORM zentry_tdn USING fu_kappl fu_objky fu_kschl return_code us_screen.

  DATA : defaults   TYPE bapidefaul,
         return     TYPE STANDARD TABLE OF bapiret2.

  CLEAR retcode.
  xscreen = us_screen.

  IF NOT tnapr-sform IS INITIAL.
    p_tdform   = tnapr-sform.
  ELSEIF NOT tnapr-fonam IS INITIAL.
    p_tdform   = tnapr-fonam.
  ENDIF.

  CLEAR: return_code,wa_header.

  p_disp = xscreen = us_screen.

  " __* Reprint
  SELECT *
    FROM nast
    INTO CORRESPONDING FIELDS OF TABLE gt_nast
    WHERE kappl EQ fu_kappl
      AND objky EQ fu_objky
      AND kschl EQ fu_kschl.

  READ TABLE gt_nast INDEX 1.
  nast = gt_nast.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    IMPORTING
      defaults = defaults
    TABLES
      return   = return.

  CALL FUNCTION 'CONVERSION_EXIT_SPDEV_INPUT'
    EXPORTING
      input  = defaults-spld
    IMPORTING
      output = p_dest.

  IF p_tdform IS INITIAL.
    p_tdform  = 'ZSDPICKSINGLE'.
  ENDIF.

  PERFORM processing_new.

  IF retcode NE 0.
    return_code = 1.
  ELSE.
    COMMIT WORK AND WAIT.                                      " INS_HP_312234
    return_code = 0.
  ENDIF.

ENDFORM.                    "zentry

*---------------------------------------------------------------------*
*       FORM PROCESSING                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PROC_SCREEN                                                   *
*---------------------------------------------------------------------*
FORM processing USING proc_screen.

  REFRESH: xlips,
           xvbfa,
           xvbuk,
           xvbup,
           yvbfa,
           yvbuk,
           yvbup.

  PERFORM get_data.
  CHECK retcode = 0.

* perform form_open using proc_screen tvst-aland.   "DEL_HP_312234
* check retcode = 0.
* perform formheader_print.
* check retcode = 0.
* perform item_print.
* check retcode = 0.
* perform form_close.
* check retcode = 0.

* <<< START_OF_INSERTION_HP_312234 >>>
* Kommimengen an Lieferungen zurückgeben, aber nicht bei Druckansicht
  IF xscreen = ' '.
    PERFORM delivery_update.
  ENDIF.
  CHECK retcode = 0.
  PERFORM form_open USING proc_screen tvst-aland.
  IF retcode = 0.
    PERFORM formheader_print.
  ENDIF.
  IF retcode = 0.
    PERFORM item_print.
  ENDIF.
  IF retcode = 0.
    PERFORM form_close.
  ENDIF.
  IF retcode <> 0.
*    abort message: picking update is done, but error in output
*    -> force rollback
    MESSAGE a073(vn).
  ENDIF.
ENDFORM.                    "processing
* <<< end_of_insertion_hp_312234 >>>

***********************************************************************
*       S U B R O U T I N E S                                         *
***********************************************************************

*---------------------------------------------------------------------*
*       FORM DELIVERY_UPDATE                                          *
*---------------------------------------------------------------------*
*       Ergänzen Lieferung um Kommissionierinformation                *
*---------------------------------------------------------------------*

* Ergänzen der Lieferungen um Kommissionierinformation
FORM delivery_update.

  DATA: BEGIN OF hvbpok OCCURS 10.     "Lieferpositionen Kommiss.
          INCLUDE STRUCTURE vbpok.
  DATA: END OF hvbpok.

  DATA: BEGIN OF sav_nast.
          INCLUDE STRUCTURE nast.
  DATA: END OF sav_nast.

* <<< START_OF_INSERTION_HP_312234 >>>
  DATA: lf_msgno LIKE sy-msgno.
  DATA: BEGIN OF lt_prot OCCURS 10.
          INCLUDE STRUCTURE prott.
  DATA: END OF lt_prot.
  DATA: ls_prot LIKE prott.
* <<< START_OF_INSERTION_HP_312234 >>>

* DATA: SYNC_FLAG TYPE C.             "synchrone Verbuchung?

* Füllen Lieferkopfdaten für Kommi-Update
  vbkok-vbeln_vl = xvbeln.
  vbkok-vbeln = vblkk-komau.

* Füllen Positionsdaten zu Liefernr.
  LOOP AT tvblkp.
    hvbpok-vbeln_vl = tvblkp-vbeln.
    hvbpok-posnr_vl = tvblkp-posnr.
    hvbpok-posnn = tvblkp-posnr.
    hvbpok-vbeln = vblkk-komau.
    hvbpok-vbtyp_n = 'Q'.
    hvbpok-pikmg = tvblkp-komng.
    hvbpok-meins = tvblkp-meins.
    hvbpok-ndifm = 0.
    hvbpok-taqui = ' '.
    IF tvblkp-posnr > '900000' AND NOT tvblkp-uecha IS INITIAL.
      hvbpok-taqui = 'X'.
    ENDIF.
    hvbpok-charg = tvblkp-charg.
    hvbpok-matnr = tvblkp-matnr.
    hvbpok-brgew = tvblkp-brgew.
    hvbpok-gewei = tvblkp-gewei.
    hvbpok-volum = tvblkp-volum.
    hvbpok-voleh = tvblkp-voleh.
    hvbpok-orpos = 0.
    APPEND hvbpok.
  ENDLOOP.

* IF NAST-VSZTP <> 4.
*    SYNC_FLAG = 'X'.
* ELSE.
*    SYNC_FLAG = ' '.
* ENDIF.

  sav_nast = nast.
  CALL FUNCTION 'SD_DELIVERY_UPDATE_PICKING'
       EXPORTING
*{   REPLACE        P01K910743                                        1
*\            nicht_sperren = 'X'
   "Start SOH: Shell Remediation Adjustment 20240321 KRS SAP Notes 1055717
            nicht_sperren = 'Y'
   "End SOH: Shell Remediation Adjustment 20240321 KRS SAP Notes 1055717
*}   REPLACE
            vbkok_wa      = vbkok
            aufrufer_t    = 'X'
* <<< START_OF_DELETION_HP_312234 >>>
*      tables
*           vbpok_tab = hvbpok.
* nast = sav_nast.
* <<< END_OF_DELETION_HP_312234 >>>
* <<< START_OF_INSERTION_HP_312234 >>>
            if_error_messages_send = ' '
       TABLES
            vbpok_tab              = hvbpok
            prot                   = lt_prot.

  nast = sav_nast.

  IF sy-subrc <> 0.
*   error handling
    retcode = sy-subrc.
    PERFORM protocol_update.
  ELSE.
*   analyse protocol
    LOOP AT lt_prot INTO ls_prot.
      lf_msgno = ls_prot-msgno.
      CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
        EXPORTING
          msg_arbgb = ls_prot-msgid
          msg_nr    = lf_msgno
          msg_ty    = ls_prot-msgty
          msg_v1    = ls_prot-msgv1
          msg_v2    = ls_prot-msgv2
          msg_v3    = ls_prot-msgv3
          msg_v4    = ls_prot-msgv4
        EXCEPTIONS
          OTHERS    = 1.
      IF ls_prot-msgty CA 'EAX'.
        retcode = 4.
      ENDIF.
    ENDLOOP.
  ENDIF.
* <<< END_OF_INSERTION_HP_312234 >>>

* Freigabe an Datenbank
* COMMIT WORK.

ENDFORM.                    "delivery_update


*---------------------------------------------------------------------*
*       FORM FORM_CLOSE                                               *
*---------------------------------------------------------------------*
*       End of printing the form                                      *
*---------------------------------------------------------------------*

FORM form_close.

  CALL FUNCTION 'CLOSE_FORM'           "...Ende Formulardruck
       EXCEPTIONS OTHERS = 1.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
    retcode = 1.
  ENDIF.
  SET COUNTRY space.

ENDFORM.                    "form_close

*---------------------------------------------------------------------*
*       FORM FORM_OPEN                                                *
*---------------------------------------------------------------------*
*       Start of printing the form                                    *
*---------------------------------------------------------------------*
*  -->  US_SCREEN  Output on screen                                   *
*                  ' ' = printer                                      *
*                  'X' = screen                                       *
*  -->  US_COUNTRY County for telecommunication and SET COUNTRY       *
*---------------------------------------------------------------------*

FORM form_open USING us_screen us_country.

  INCLUDE rvadopfo.

ENDFORM.                    "form_open

*---------------------------------------------------------------------*
*       FORM FORMHEADER_PRINT                                         *
*---------------------------------------------------------------------*
*       Printing Formheader                                           *
*---------------------------------------------------------------------*

FORM formheader_print.

  PERFORM sender.

ENDFORM.                    "formheader_print

*---------------------------------------------------------------------*
*       FORM GET_DATA                                                 *
*---------------------------------------------------------------------*
*       General provision of data for the form                        *
*---------------------------------------------------------------------*

FORM get_data.

  DATA: vblkp_lines      TYPE p.
  DATA  ls_tvst          LIKE tvst.                         "N 442278
  DATA l_tdobject LIKE stxh-tdobject.

  DATA: lv_lzone LIKE zslockanvas-lzone,
        lv_kunnr LIKE kna1-kunnr,
        lv_kunn2 LIKE knvp-kunn2.

  DATA: lv_bednr LIKE ekpo-bednr.

* Beschaffen View
  xvbeln = nast-objky.
  CALL FUNCTION 'RV_DELIVERY_PICK_VIEW'
    EXPORTING
      vbeln     = xvbeln
      zweck     = 'D'
      spras     = nast-spras
    IMPORTING
      vblkk_wa  = vblkk
    TABLES
      vblkp_tab = tvblkp
    EXCEPTIONS
      OTHERS    = 1.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

* enable external sending                    "v N 442278
  IF NOT nast-tcode IS INITIAL.
    SELECT SINGLE * INTO ls_tvst FROM tvst
      WHERE vstel = vblkk-vstel.
    addr_key-addrnumber = ls_tvst-adrnr.
  ENDIF.                                                    "^ N 442278

* gibt es zu kommissionierende Positionen, ggf. sortieren
  DESCRIBE TABLE tvblkp LINES vblkp_lines.
  IF vblkp_lines GT 0.

* Nummernvergabe Kommissionierauftrag
    CLEAR vblkk-komau.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'SD_PICKING'
      IMPORTING
        number      = vblkk-komau
      EXCEPTIONS
        OTHERS      = 1.
    IF sy-subrc NE 0.
    ENDIF.

    IF vblkk-komau IS INITIAL.
      vblkk-komau = sy-datum+2.
      vblkk-komau+6(4) = sy-uzeit(4).
    ENDIF.

    PERFORM sort_pick_list.
    retcode = 0.
  ELSE.
    retcode = 4.
    syst-msgid = 'VN'.
    syst-msgno = '202'.
    syst-msgty = 'E'.
    syst-msgv1 = vblkk-vbeln.
    PERFORM protocol_update.
    CHECK 1 = 2.
  ENDIF.

* TPRIO
  SELECT SINGLE bezei INTO va_bezei FROM tprit
  WHERE spras EQ sy-langu AND lprio EQ vblkk-lprio.

** Add by Budi 07/06/2007 ----------------------------------
** Req. by hgunawan
  CLEAR: va_bnddt,va_vgbel,va_name,va_sotext1,va_sotext2,va_sotext3,va_lines.
  REFRESH: va_lines.

  SELECT SINGLE vgbel INTO va_vgbel
    FROM lips WHERE vbeln = vblkk-vbeln.

  SELECT SINGLE bnddt INTO va_bnddt
    FROM vbak WHERE vbeln = va_vgbel.

*  va_name = vblkk-vbeln.
  va_name = va_vgbel.

* check document header text
  SELECT SINGLE tdobject FROM stxh CLIENT SPECIFIED
    INTO l_tdobject
    WHERE mandt    = sy-mandt
      AND tdobject = 'VBBK'
      AND tdname   = va_name
      AND tdid     = '0002'
      AND tdspras  = sy-langu.

  IF sy-subrc = 0.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        client                        = sy-mandt
        id                            = '0002'
        language                      = sy-langu
        name                          = va_name
        object                        = 'VBBK'
*       ARCHIVE_HANDLE                = 0
*       LOCAL_CAT                     = ' '
*     IMPORTING
*       HEADER                        =
      TABLES
        lines                         = va_lines
*     EXCEPTIONS
*       ID                            = 1
*       LANGUAGE                      = 2
*       NAME                          = 3
*       NOT_FOUND                     = 4
*       OBJECT                        = 5
*       REFERENCE_CHECK               = 6
*       WRONG_ACCESS_TO_ARCHIVE       = 7
*       OTHERS                        = 8
              .
    IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    LOOP AT va_lines.
      CASE sy-tabix.
        WHEN 1.
          va_sotext1 = va_lines-tdline.
        WHEN 2.
          va_sotext2 = va_lines-tdline.
        WHEN 3.
          va_sotext3 = va_lines-tdline.
      ENDCASE.
    ENDLOOP.

  ENDIF.
** Endadd --------------------------------------------------

* Lesen Versandstelle
  IF vblkk-vstel EQ space.
    CLEAR: tvst, tvstt.
  ELSE.
    SELECT SINGLE * FROM tvst WHERE vstel EQ vblkk-vstel.
    IF sy-subrc NE 0.
      CLEAR tvst.
      syst-msgid = 'VN'.
      syst-msgno = '203'.
      syst-msgty = 'E'.
      syst-msgv1 = 'TVST'.
      syst-msgv2 = syst-subrc.
      PERFORM protocol_update.
    ENDIF.
    SELECT SINGLE * FROM tvstt WHERE spras EQ nast-spras
                                 AND vstel EQ vblkk-vstel.
    IF sy-subrc NE 0.
      CLEAR tvstt.
      syst-msgid = 'VN'.
      syst-msgno = '203'.
      syst-msgty = 'E'.
      syst-msgv1 = 'TVSTT'.
      syst-msgv2 = syst-subrc.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.

**** Change Request to display
**** customer code for kmm do intercompany
**** by iway

  DATA: lv_likp TYPE likp.
  DATA: li_lips TYPE STANDARD TABLE OF lips WITH HEADER LINE.
  DATA: lv_ekko TYPE ekko.
  DATA: lv_ekpv TYPE ekpv.
  DATA: lv_ebeln TYPE ebeln.
  DATA: lv_kna1 TYPE kna1.
  DATA: li_line TYPE STANDARD TABLE OF tline WITH HEADER LINE.
  DATA: lv_id TYPE thead-tdid VALUE 'F01'.
  DATA: lv_name TYPE thead-tdname.
  DATA: lv_object TYPE thead-tdobject VALUE 'EKKO'.
  break tds_dev01.
  SELECT SINGLE * INTO lv_likp
    FROM likp WHERE vbeln = xvbeln.
  IF sy-subrc EQ 0 AND lv_likp-vstel = '3600'.

    SELECT * INTO TABLE li_lips
      FROM lips WHERE vbeln = xvbeln.

    IF sy-subrc EQ 0.
      LOOP AT li_lips WHERE vgbel IS NOT INITIAL.
        SELECT SINGLE * INTO lv_ekko
          FROM ekko WHERE ebeln = li_lips-vgbel.

        IF sy-subrc EQ 0.
          lv_name = lv_ekko-ebeln.
          CALL FUNCTION 'READ_TEXT'
            EXPORTING
              id                      = lv_id
              language                = sy-langu
              name                    = lv_name
              object                  = lv_object
            TABLES
              lines                   = li_line
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

          ELSE.
            READ TABLE li_line INDEX 1.
            IF sy-subrc EQ 0.
              lv_ebeln = li_line-tdline.
              SELECT SINGLE * INTO lv_ekpv FROM ekpv
                WHERE ebeln = lv_ebeln AND kunnr NE ''.
              IF sy-subrc EQ 0.
                SELECT SINGLE *
                  FROM kna1 WHERE kunnr =  lv_ekpv-kunnr.
                IF sy-subrc EQ 0.
                  EXIT.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ELSEIF sy-subrc EQ 0 AND lv_likp-lfart = 'ZSFK'.

    wa_header-lfart = lv_likp-lfart.

    SELECT SINGLE * INTO li_lips
      FROM lips WHERE vbeln = xvbeln.

    SELECT SINGLE bednr lgort INTO (lv_bednr,wa_header-lgort2)
      FROM ekpo WHERE ebeln = li_lips-vgbel.

*    SELECT SINGLE lzone INTO lv_lzone
*      FROM zslockanvas WHERE vstel = lv_likp-vstel
*                         AND lgort = wa_header-lgort2.

*    SELECT SINGLE kunnr INTO lv_kunnr
*      FROM kna1 WHERE lzone = lv_lzone
*                  AND land1 = 'ID'.

*    SELECT SINGLE kunn2 INTO lv_kunn2
*      FROM knvp WHERE kunnr = lv_kunnr
*                  AND vkorg = '8020'
*                  AND vtweg = '10'
*                  AND spart = '00'
*                  AND parvw = 'ZS'.

*    SELECT SINGLE pernr INTO wa_header-pernr
*      FROM knvp WHERE kunnr = lv_kunn2
*                  AND vkorg = '8020'
*                  AND vtweg = '10'
*                  AND spart = '00'
*                  AND parvw = 'VE'.
    SELECT SINGLE pernr INTO wa_header-pernr
      FROM zsfammdt001h WHERE vkorg = lv_likp-vkorg
                          AND vkbur = lv_likp-vstel
                          AND noposfa = lv_bednr.
*                          AND vbeln = lv_likp-vbeln.

    SELECT SINGLE sname INTO wa_header-sname
      FROM pa0001 WHERE pernr = wa_header-pernr .

  ELSEIF sy-subrc EQ 0 AND lv_likp-vkorg = '8380'.
    SELECT SINGLE bezei INTO wa_header-bezei
      FROM tprit WHERE spras = sy-langu
                   AND lprio = lv_likp-lprio.
  ENDIF.

  IF lv_likp IS NOT INITIAL.
    CASE lv_likp-lprio.
      WHEN '20'.
        wa_header-cod = 'CBD'.
      WHEN '21'.
        wa_header-cod = 'COD'.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.
**** End Change Request

ENDFORM.                    "get_data

*---------------------------------------------------------------------*
*       FORM GET_SERIAL_NO                                            *
*---------------------------------------------------------------------*
*       In this routine the serialnumbers are fetched from the        *
*       database.                                                     *
*---------------------------------------------------------------------*

FORM get_serial_no.

  REFRESH tsernr.
  REFRESH tsernr_print.
  CHECK vblkp-anzsn > 0.
* Read the Serialnumbers of a Position.
  CALL FUNCTION 'SERIAL_LS_PRINT'
    EXPORTING
      vbeln  = vblkp-vbeln
      posnr  = vblkp-posnr
    TABLES
      iserls = tsernr.

* Process the stringtable for Printing.
  CALL FUNCTION 'PROCESS_SERIALS_FOR_PRINT'
    EXPORTING
      i_boundary_left             = '(_'
      i_boundary_right            = '_)'
      i_sep_char_strings          = ',_'
      i_sep_char_interval         = '_-_'
      i_use_interval              = 'X'
      i_boundary_method           = 'C'
      i_line_length               = 50
      i_no_zero                   = 'X'
      i_alphabet                  = sy-abcde
      i_digits                    = '0123456789'
      i_special_chars             = '-'
      i_with_second_digit         = ' '
    TABLES
      serials                     = tsernr
      serials_print               = tsernr_print
    EXCEPTIONS
      boundary_missing            = 01
      interval_separation_missing = 02
      length_to_small             = 03
      internal_error              = 04
      wrong_method                = 05
      wrong_serial                = 06
      two_equal_serials           = 07
      serial_with_wrong_char      = 08
      serial_separation_missing   = 09.

  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "get_serial_no
*---------------------------------------------------------------------*
*       FORM ITEM_PRINT                                               *
*---------------------------------------------------------------------*
*       Printout of the items                                         *
*---------------------------------------------------------------------*

FORM item_print.

  DATA: e_werks LIKE tvblkp-werks VALUE ' ',
        e_lgort LIKE tvblkp-lgort VALUE ' ',
        e_lgnum LIKE tvblkp-lgnum VALUE ' ',
        e_mbdat LIKE tvblkp-mbdat VALUE IS INITIAL.

  DATA: ld_charg  LIKE tvblkp-charg.

  CALL FUNCTION 'WRITE_FORM'           "Activate header
       EXPORTING  element = 'ITEM_HEADER'
                  type    = 'TOP'
       EXCEPTIONS OTHERS  = 1.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.
  va_vgpos = 0.
  SORT tvblkp BY vgpos.
  LOOP AT tvblkp.
    ld_charg  = tvblkp-charg.
    vblkp = tvblkp.
*  neue Seite bei Wechsel Werk/Lagerort/Kommidatum/WM-Lager
    IF e_werks NE tvblkp-werks OR
       e_lgort NE tvblkp-lgort OR
       e_lgnum NE tvblkp-lgnum OR
       e_mbdat NE tvblkp-mbdat.
      IF sy-tabix > 1.
        MOVE svblkp TO vblkp.
        CALL FUNCTION 'CONTROL_FORM'
          EXPORTING
            command = 'NEW-PAGE'.
        MOVE tvblkp TO vblkp.
      ENDIF.
      e_werks = tvblkp-werks.
      e_lgort = tvblkp-lgort.
      e_lgnum = tvblkp-lgnum.
      e_mbdat = tvblkp-mbdat.
    ENDIF.
* Druck WM-Angaben falls vorhanden
    IF tvblkp-lgpla NE space.
      tvblkp-lgpbe = tvblkp-lgpla.
      vblkp-lgpbe = tvblkp-lgpla.
    ENDIF.

*on change of vblkp-vgpos.
* Druck der einzelnen Zeile
    IF va_vgpos NE tvblkp-vgpos.
      CLEAR va_komng.
      LOOP AT tvblkp WHERE vgpos EQ tvblkp-vgpos.
        va_komng = va_komng + tvblkp-komng.
      ENDLOOP.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE'.
    ENDIF.
    va_vgpos = vblkp-vgpos.
    IF NOT tvblkp-charg IS INITIAL.
* tambahan
      SELECT SINGLE vfdat INTO va_vfdat FROM mch1
*      where matnr eq tvblkp-matnr and charg eq  tvblkp-charg.
      WHERE matnr EQ tvblkp-matnr AND charg EQ  ld_charg.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'CHARGE'
        EXCEPTIONS
          OTHERS  = 1.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ENDIF.
    PERFORM get_serial_no.
    PERFORM item_serial_no_print.
    svblkp = tvblkp.
  ENDLOOP.

  CALL FUNCTION 'WRITE_FORM'           "Deactivate Header
       EXPORTING  element  = 'ITEM_HEADER'
                  function = 'DELETE'
                  type     = 'TOP'
       EXCEPTIONS OTHERS   = 1.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "item_print

*---------------------------------------------------------------------*
*       FORM ITEM_SERIAL_NO_PRINT                                     *
*---------------------------------------------------------------------*
*       Printout of the item serialnumbers                            *
*---------------------------------------------------------------------*

FORM item_serial_no_print.

  LOOP AT tsernr_print.
    komser = tsernr_print.
    IF sy-tabix = 1.
*     Output of the Headerline
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE_SERIAL_NO_HEADER'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ELSE.
*     Output of the following printlines
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE_SERIAL_NO'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ENDIF.
    AT LAST.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = 'NEW-LINE'.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ENDAT.
  ENDLOOP.

ENDFORM.                    "item_serial_no_print

*---------------------------------------------------------------------*
*       FORM PROTOCOL_UPDATE                                          *
*---------------------------------------------------------------------*
*       The messages are collected for the processing protocol.       *
*---------------------------------------------------------------------*

FORM protocol_update.

  CHECK xscreen = space.
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = syst-msgid
      msg_nr    = syst-msgno
      msg_ty    = syst-msgty
      msg_v1    = syst-msgv1
      msg_v2    = syst-msgv2
      msg_v3    = syst-msgv3
      msg_v4    = syst-msgv4
    EXCEPTIONS
      OTHERS    = 1.

ENDFORM.                    "protocol_update

*---------------------------------------------------------------------*
*       FORM SENDER                                                   *
*---------------------------------------------------------------------*
*       This routine determines the address of the sender (Table VBUR)*
*---------------------------------------------------------------------*

FORM sender.


ENDFORM.                    "sender

INCLUDE mv50bfz1.

*&---------------------------------------------------------------------*
*&      Form  PROCESSING_NEW
*&---------------------------------------------------------------------*
FORM processing_new  .
  PERFORM f_init_data.
  PERFORM get_data.
  CHECK retcode = 0.
  IF xscreen = ' '.
    PERFORM delivery_update.
  ENDIF.
  PERFORM f_validate_data.
  PERFORM f_process_data.
  PERFORM f_print_form.
  PERFORM f_free_memory.
ENDFORM.                    " PROCESSING_NEW

INCLUDE zrvadek01f01.
