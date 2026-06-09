*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

FORM f_init_data.

  r_kschl-option = 'EQ'.
  r_kschl-sign   = 'I'.
  r_kschl-low    = 'ZD04'.
  APPEND r_kschl.

  r_kschl-option = 'EQ'.
  r_kschl-sign   = 'I'.
  r_kschl-low    = 'ZN01'.
  APPEND r_kschl.

  r_kschl-option = 'EQ'.
  r_kschl-sign   = 'I'.
  r_kschl-low    = 'ZNSP'.
  APPEND r_kschl.

  r_kschl-option = 'EQ'.
  r_kschl-sign   = 'I'.
  r_kschl-low    = 'ZDB3'.
  APPEND r_kschl.

  r_kschl-option = 'EQ'.
  r_kschl-sign   = 'I'.
  r_kschl-low    = 'ZDB4'.
  APPEND r_kschl.

  r_kschl2-option = 'EQ'.
  r_kschl2-sign   = 'I'.
  r_kschl2-low    = 'ZHJP'.
  APPEND r_kschl2.

  r_kschl2-option = 'EQ'.
  r_kschl2-sign   = 'I'.
  r_kschl2-low    = 'ZADJ'.
  APPEND r_kschl2.

  r_kschl2-option = 'EQ'.
  r_kschl2-sign   = 'I'.
  r_kschl2-low    = 'ZHJM'.
  APPEND r_kschl2.

  r_kschl2-option = 'EQ'.
  r_kschl2-sign   = 'I'.
  r_kschl2-low    = 'ZHSC'.
  APPEND r_kschl2.

  r_kschl2-option = 'EQ'.
  r_kschl2-sign   = 'I'.
  r_kschl2-low    = 'ZHMC'.
  APPEND r_kschl2.

  r_kschl2-option = 'EQ'.
  r_kschl2-sign   = 'I'.
  r_kschl2-low    = 'ZHIF'.
  APPEND r_kschl2.

** Add by budi req. by popo 11/02/2011
  r_kschl2-option = 'EQ'.
  r_kschl2-sign   = 'I'.
  r_kschl2-low    = 'ZTRP'.
  APPEND r_kschl2.
** Add by budi req. by popo 11/02/2011

* Penambahan untuk VAT & PPh22
  r_kschl3-option = 'EQ'.
  r_kschl3-sign   = 'I'.
  r_kschl3-low    = 'ZTX1'.
  APPEND r_kschl3.

  r_kschl3-option = 'EQ'.
  r_kschl3-sign   = 'I'.
  r_kschl3-low    = 'ZTX5'.
  APPEND r_kschl3.

  r_cancl-sign   = 'I'.
  r_cancl-option = 'BT'.
  r_cancl-low    = 'ZR03'.
  r_cancl-high   = 'ZR04'.
  APPEND r_cancl.

  r_cancl-sign   = 'I'.
  r_cancl-option = 'BT'.
  r_cancl-low    = 'ZI03'.
  r_cancl-high   = 'ZI04'.
  APPEND r_cancl.

****Get user defaults
**  CLEAR: t_user, t_user[].
**  t_user-bname = sy-uname.
**  APPEND t_user.
**  CALL FUNCTION 'SUSR_GET_USER_DEFAULTS'
**       EXPORTING
**            langu = sy-langu
**       TABLES
**            users = t_user.
**
**
**  d_month = p_date+4(2).
**  CONCATENATE p_date+0(6) '01' INTO d_month_begin.
**
***-- Get Last Day
**  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
**       EXPORTING
**            day_in            = p_date
**      IMPORTING
**            last_day_of_month = d_month_end
***       EXCEPTIONS
***            DAY_IN_NO_DATE    = 1
***            OTHERS            = 2
**            .
**  IF sy-subrc <> 0.
*** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
***         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
**  ENDIF.
**
**
**  IF p_chk1 = 'X'.
**    r_versb-sign = 'I'.
**    r_versb-option = 'EQ'.
**    r_versb-low = 'DL'.
**    APPEND r_versb.
**  ENDIF.
**  IF p_chk2 = 'X'.
**    r_versb-sign = 'I'.
**    r_versb-option = 'EQ'.
**    r_versb-low = 'TN'.
**    APPEND r_versb.
**  ENDIF.
**  IF p_chk3 = 'X'.
**    r_versb-sign = 'I'.
**    r_versb-option = 'EQ'.
**    r_versb-low = 'TF'.
**    APPEND r_versb.
**  ENDIF.
**  IF p_chk4 = 'X'.
**    r_versb-sign = 'I'.
**    r_versb-option = 'EQ'.
**    r_versb-low = 'WF'.
**    APPEND r_versb.
**  ENDIF.
**  IF p_chk5 = 'X'.
**    r_versb-sign = 'I'.
**    r_versb-option = 'EQ'.
**    r_versb-low = 'WN'.
**    APPEND r_versb.
**  ENDIF.
**
**  r_pdatu-sign = 'I'.
**  r_pdatu-option = 'BT'.
**  r_pdatu-low = d_month_begin.
**  r_pdatu-high = d_month_end.
**  APPEND r_pdatu.
**
***-- Get Range for Next month (5 Months after)
**  PERFORM f_get_month_after TABLES r_pdatu1.
**  PERFORM f_get_month_after TABLES r_pdatu2.
**  PERFORM f_get_month_after TABLES r_pdatu3.
**  PERFORM f_get_month_after TABLES r_pdatu4.
**  PERFORM f_get_month_after TABLES r_pdatu5.

ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_month_after                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_DATE                                                       *
*---------------------------------------------------------------------*
FORM f_get_month_after TABLES fu_date STRUCTURE r_pdatu.
  d_month = d_month + 1.
  CONCATENATE d_month_begin+0(4) d_month '01' INTO d_month_begin.

*-- Get Last Day
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = d_month_begin
    IMPORTING
      last_day_of_month = d_month_end
*       EXCEPTIONS
*     DAY_IN_NO_DATE    = 1
*     OTHERS            = 2
    .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  fu_date-sign = 'I'.
  fu_date-option = 'BT'.
  fu_date-low = d_month_begin.
  fu_date-high = d_month_end.
  APPEND fu_date.
ENDFORM.                    "f_get_month_after


*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA : lt_project TYPE STANDARD TABLE OF zproject,
         ls_project LIKE LINE OF lt_project.

  DATA : lv_vbeln     TYPE vbrp-vbeln.

**  DATA: l_vkbur LIKE vbrp-vkbur.
**  RANGES: r_fkdat for VBRK-FKDAT.
**  r_fkdat-OPTION = 'BT'.
**  r_fkdat-SIGN = 'I'.
**  concatenate s_fkdat-low+0(6) '01' into r_fkdat-LOW.
**  call function 'LAST_DAY_OF_MONTHS'
**        exporting
**              DAY_IN    =  r_fkdat-LOW
**        importing
**              LAST_DAY_OF_MONTH = r_fkdat-high.
**  append r_fkdat.

** For current vkbur replaced with werks!
** in the future, may be vkbur is used again
  SELECT a~fkdat a~vbeln a~kunag a~kunrg a~waerk a~knumv b~mwsbp a~xblnr
        b~werks b~matnr b~arktx b~vgtyp b~brtwr b~fkimg b~vrkme
        b~posnr a~fkart a~erdat a~sfakn
    INTO CORRESPONDING FIELDS OF TABLE i_hd
    FROM vbrk AS a JOIN vbrp AS b ON a~vbeln EQ b~vbeln
    WHERE a~vbeln IN s_vbeln
    AND   a~vkorg EQ p_vkorg
    AND   a~fkdat IN s_fkdat
**  AND   a~fkdat IN r_fkdat
    AND   a~kunag IN s_kunnr
**  AND   a~fksto NE 'X'
    AND   b~matnr IN s_matnr
**  AND   b~vkbur IN s_vkbur
    AND   b~werks IN s_vkbur
    AND   a~expkz EQ space
    AND   a~kunrg IN s_kunrg
    ORDER BY a~kunag.



*  break bcdik.
* check whether s_raube = ""
*  if s_mtart is initial.
  CHECK NOT i_hd[] IS INITIAL.
  SELECT matnr matkl
  FROM mara
  INTO CORRESPONDING FIELDS OF TABLE i_matnr
  FOR ALL ENTRIES IN i_hd
  WHERE matnr EQ i_hd-matnr AND
        mtart IN s_mtart AND
        matkl IN s_matkl.
  SORT i_matnr BY matnr.
*  endif.

  CHECK NOT i_hd[] IS INITIAL.
  SELECT vbeln fakturno
  FROM zgdtxdt0002
  INTO CORRESPONDING FIELDS OF TABLE i_zgdtxdt0002
  FOR ALL ENTRIES IN i_hd
  WHERE vbeln = i_hd-vbeln.
  SORT i_zgdtxdt0002 BY vbeln.

*  break bcdik.

***(RAHMADI) ALWAYS MAKE SURE TABLE USED FOR ALL ENTRIES IS NOT EMPTY
***OTHERWISE THE WHOLE DATA WILL BE SELECTED
  CHECK NOT i_hd[] IS INITIAL.
  SELECT kunnr name1 FROM kna1
  INTO CORRESPONDING FIELDS OF TABLE i_cust
  FOR ALL ENTRIES IN i_hd
  WHERE kunnr EQ i_hd-kunag.
  SORT i_cust BY kunnr.

  SELECT knumv kposn kschl kwert waers FROM konv
  INTO CORRESPONDING FIELDS OF TABLE i_konv
  FOR ALL ENTRIES IN i_hd
  WHERE knumv EQ i_hd-knumv
  AND   kposn EQ i_hd-posnr
  AND   kschl IN r_kschl
  AND   kappl EQ 'V'.
  SORT i_konv BY knumv kposn kschl.

  LOOP AT i_konv.
*    MOVE-CORRESPONDING i_konv TO i_konvsum.
*    COLLECT i_konvsum.
    CASE i_konv-kschl.
      WHEN 'ZD04'.
        MOVE-CORRESPONDING i_konv TO i_konvsum.
        COLLECT i_konvsum.
      WHEN 'ZN01' OR 'ZNSP'.
        MOVE-CORRESPONDING i_konv TO i_konvzn01.
        COLLECT i_konvzn01.
      WHEN 'ZDB3'.
        MOVE-CORRESPONDING i_konv TO i_konvzdb3.
        COLLECT i_konvzdb3.
      WHEN 'ZDB4'.
        MOVE-CORRESPONDING i_konv TO i_konvzdb4.
        COLLECT i_konvzdb4.
    ENDCASE.
  ENDLOOP.

  SELECT knumv kposn kschl kwert kbetr waers FROM konv
  INTO CORRESPONDING FIELDS OF TABLE i_konv2
  FOR ALL ENTRIES IN i_hd
  WHERE knumv EQ i_hd-knumv
  AND   kschl IN r_kschl2
  AND   kinak EQ space.
  SORT i_konv2 BY knumv kposn kschl.

  LOOP AT i_konv2.
    MOVE-CORRESPONDING i_konv2 TO i_konv2sum.
    COLLECT i_konv2sum.
  ENDLOOP.

* Penambahan untuk VAT & PPh22
  SELECT knumv kposn kschl kwert kbetr waers FROM konv
  INTO CORRESPONDING FIELDS OF TABLE i_konv3
  FOR ALL ENTRIES IN i_hd
  WHERE knumv EQ i_hd-knumv
  AND   kschl IN r_kschl3
  AND   kinak EQ space.
  SORT i_konv2 BY knumv kposn kschl.

*-modify-start by idub 20070115
  CHECK NOT i_hd[] IS INITIAL.
  SELECT vbeln invo1 invo2 gjahr
  FROM zgdsdkomer
  INTO CORRESPONDING FIELDS OF TABLE i_komernr
  FOR ALL ENTRIES IN i_hd
  WHERE vbeln EQ i_hd-vbeln.
  SORT i_komernr BY vbeln.
*-modify-end.


  CLEAR wa_dt.

  LOOP AT i_hd INTO wa_hd.

    IF wa_hd-fkart = 'ZR02'.
      SELECT SINGLE vbelv INTO wa_hd-xblnr
        FROM vbfa WHERE vbeln = wa_hd-vbeln.
    ENDIF.

****    l_vkbur = wa_hd-vkbur.
****    AT NEW kunag.
****      wa_dt-kunag = wa_hd-kunag.
****      wa_dt-vkbur = l_vkbur.
****      wa_dt-matnr = space.
****      wa_dt-arktx = space.
****      wa_dt-brtwr = space.
****      wa_dt-fkimg = space.
****      APPEND wa_dt TO i_dt.
****    ENDAT.


****(RAHMADI) ALWAYS USE READ BINARY SEARCH WHERE POSSIBLE
****BUT MAKE SURE THE TABLE IS SORTED FIRST BASED ON THE SELECTION
    READ TABLE i_matnr INTO wa_matnr
    WITH KEY matnr = wa_hd-matnr
    BINARY SEARCH.
    IF sy-subrc NE 0.
      CLEAR: wa_dt,
             wa_konvsum,
             wa_cust.
      CONTINUE.
    ENDIF.

    wa_dt-matkl = wa_matnr-matkl.


    READ TABLE i_zgdtxdt0002 INTO wa_zgdtxdt0002
    WITH KEY vbeln = wa_hd-vbeln
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      wa_dt-fakno = wa_zgdtxdt0002-fakturno.
    ELSE.
      wa_dt-fakno = space.
    ENDIF.


    IF p_po = 'X'.
*      IF s_bsart IS INITIAL.
*        SELECT SINGLE ebeln
*         FROM ekbe
*         INTO (wa_hd-ebeln)
*         WHERE xblnr EQ wa_hd-xblnr.
*
*        SELECT SINGLE bsart FROM ekko
*        INTO (wa_dt-bsart)
*        WHERE ebeln EQ wa_hd-ebeln AND
*              bsart IN ('ZSUB', 'ZB', 'RZB').
*      ELSE.

      SELECT *
        FROM zproject
        INTO CORRESPONDING FIELDS OF TABLE lt_project
        WHERE name = 'ZGDSDR0002_1'
          AND datab >= wa_hd-erdat
          AND flag  = 'X'.

      IF sy-subrc = 0.
        PERFORM f_get_po_type USING '1' wa_hd-xblnr ''
                              CHANGING wa_hd-ebeln.
      ELSE.
        IF p_vkorg = '8010'.
          IF wa_hd-fkart = 'ZR03' OR
            wa_hd-fkart = 'ZI02' OR
            wa_hd-fkart = 'ZI05' OR
            wa_hd-fkart = 'ZR02' OR
            wa_hd-fkart = 'ZKM5'.
            lv_vbeln  = wa_hd-vbeln.
          ELSE.
            lv_vbeln  = wa_hd-xblnr.
          ENDIF.
          PERFORM f_get_po_type USING '2' lv_vbeln wa_hd-posnr
                                CHANGING wa_hd-ebeln.
        ELSEIF p_vkorg = '8030' OR p_vkorg = '8040'.
          PERFORM f_get_po_type USING '2' wa_hd-vbeln wa_hd-posnr
                                CHANGING wa_hd-ebeln.
        ELSE.
          PERFORM f_get_po_type USING '1' wa_hd-xblnr ''
                                CHANGING wa_hd-ebeln.
        ENDIF.
      ENDIF.

*      ENDIF.
    ENDIF.

    IF p_so = 'X'.
      SELECT SINGLE vbelv
       FROM vbfa
       INTO (wa_hd-vbelv)
       WHERE vbeln EQ wa_hd-vbeln AND
             vbtyp_v IN ('C','H','K','L').

*      IF s_auart IS INITIAL.
*        SELECT SINGLE auart
*         FROM vbak
*         INTO (wa_dt-auart)
*         WHERE vbeln EQ wa_hd-vbelv AND
*            auart IN ('ZO01','ZO02','ZO03','ZR01','ZR02','ZR03','ZA00',
*                         'ZA01','ZA02','ZA03','ZA04','ZA05','ZA06').
*      ELSE.
      SELECT SINGLE auart
       FROM vbak
       INTO (wa_dt-auart)
       WHERE vbeln EQ wa_hd-vbelv AND
             auart IN s_auart.
*      ENDIF.

    ENDIF.

    IF wa_dt-bsart EQ space AND wa_dt-auart EQ space.
      CLEAR: wa_dt,
             wa_konvsum,
             wa_cust.
      CONTINUE.
    ENDIF.


****(RAHMADI) ALWAYS USE READ BINARY SEARCH WHERE POSSIBLE
****BUT MAKE SURE THE TABLE IS SORTED FIRST BASED ON THE SELECTION
    READ TABLE i_cust INTO wa_cust
    WITH KEY kunnr = wa_hd-kunag
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      wa_dt-name1 = wa_cust-name1.
    ENDIF.

    READ TABLE i_cust INTO wa_cust
    WITH KEY kunnr = wa_hd-kunrg
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      wa_dt-name2 = wa_cust-name1.
    ENDIF.

***(RAHMADI) IS IT ONLY ONE TYPE OF CONDITION USED HERE? ONE LINE ITEM
***COULD HAVE MORE THAN ONE COND TYPE, LOOP MIGHT BE NECESSARY
    READ TABLE i_konvsum INTO wa_konvsum
    WITH KEY knumv = wa_hd-knumv
             kposn = wa_hd-posnr
             kschl = 'ZD04'
             BINARY SEARCH.
    IF sy-subrc EQ 0.
      wa_dt-kwert = wa_konvsum-kwert.
      wa_dt-waers = wa_konvsum-waers.
      wa_dt-knumv = wa_hd-knumv.
      wa_dt-posnr = wa_hd-posnr.
    ENDIF.

    wa_dt-zn01 = VALUE #( i_konvzn01[ knumv = wa_hd-knumv
                                      kposn = wa_hd-posnr
                                      kschl = 'ZN01' ]-kwert OPTIONAL ).
    IF wa_dt-zn01 IS INITIAL.
      wa_dt-zn01 = VALUE #( i_konvzn01[ knumv = wa_hd-knumv
                                        kposn = wa_hd-posnr
                                        kschl = 'ZNSP' ]-kwert OPTIONAL ).
    ENDIF.

    wa_dt-zdb3 = VALUE #( i_konvzdb3[ knumv = wa_hd-knumv
                                      kposn = wa_hd-posnr
                                      kschl = 'ZDB3' ]-kwert OPTIONAL ).
    wa_dt-zdb4 = VALUE #( i_konvzdb4[ knumv = wa_hd-knumv
                                      kposn = wa_hd-posnr
                                      kschl = 'ZDB4' ]-kwert OPTIONAL ).

    "Retur
    IF wa_dt-bsart = 'RZB' OR wa_hd-sfakn IS NOT INITIAL.
      MULTIPLY wa_dt-zn01 BY -1.
*      MULTIPLY wa_dt-zdb3 BY -1.
*      MULTIPLY wa_dt-zdb4 BY -1.
    ENDIF.

    READ TABLE i_konv2sum INTO wa_konv2sum
    WITH KEY knumv = wa_hd-knumv
             kposn = wa_hd-posnr
             BINARY SEARCH.
    IF sy-subrc EQ 0.
      wa_dt-kbetr = wa_konv2sum-kbetr.
      wa_dt-kwert_val = wa_konv2sum-kwert.
    ENDIF.

    LOOP AT i_konv3 INTO wa_konv3
                    WHERE knumv EQ wa_hd-knumv AND
                          kposn EQ wa_hd-posnr.
      CASE wa_konv3-kschl.
        WHEN 'ZTX1'.
          IF wa_hd-fkart IN r_cancl.
            wa_dt-ztx1  = wa_konv3-kwert * -1.
          ELSEIF wa_hd-fkart = 'ZR02'.
            wa_dt-ztx1  = wa_konv3-kwert * -1.
          ELSE.
            wa_dt-ztx1  = wa_konv3-kwert.
          ENDIF.
        WHEN 'ZTX5'.
          IF wa_hd-fkart IN r_cancl.
            wa_dt-ztx5  = wa_konv3-kwert * -1.
          ELSEIF wa_hd-fkart = 'ZR02'.
            wa_dt-ztx5  = wa_konv3-kwert * -1.
          ELSE.
            wa_dt-ztx5  = wa_konv3-kwert.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    wa_dt-kunag = wa_hd-kunag.
    wa_dt-kunrg = wa_hd-kunrg.
**  For temporary vkbur replaced by werks!
    wa_dt-vkbur = wa_hd-werks.
    wa_dt-vbeln = wa_hd-vbeln.
    wa_dt-abper = wa_hd-fkdat(6).
    wa_dt-fkdat = wa_hd-fkdat.
    wa_dt-vgtyp = wa_hd-vgtyp.
    wa_dt-matnr = wa_hd-matnr.
    wa_dt-arktx = wa_hd-arktx.
    wa_dt-brtwr = wa_hd-brtwr.
    wa_dt-fkimg = wa_hd-fkimg.
    wa_dt-vrkme = wa_hd-vrkme.
    wa_dt-waerk = wa_hd-waerk.
    wa_dt-fkart = wa_hd-fkart.


* coding below, if using KBETR
    IF wa_dt-vgtyp = 'J' OR wa_dt-vgtyp = 'L'.
      IF wa_hd-fkart IN r_cancl.
        wa_dt-kwert_iv = wa_dt-kwert_val * -1.
        wa_dt-fkimg_iv = wa_hd-fkimg * -1.
        wa_dt-tax = wa_hd-mwsbp * -1.
        wa_dt-kwert = wa_dt-kwert.
        wa_dt-netsls = wa_dt-kwert_iv + wa_dt-tax - wa_dt-kwert.
      ELSE.
        wa_dt-kwert_iv = wa_dt-kwert_val.
        wa_dt-fkimg_iv = wa_hd-fkimg.
        wa_dt-tax = wa_hd-mwsbp.
        wa_dt-kwert = wa_dt-kwert * -1.
        wa_dt-netsls = wa_dt-kwert_iv + wa_dt-tax - wa_dt-kwert.
        MULTIPLY wa_dt-zdb3 BY -1.
        MULTIPLY wa_dt-zdb4 BY -1.
      ENDIF.
    ELSEIF wa_dt-vgtyp = 'T' OR wa_dt-vgtyp = 'K'.
      IF wa_hd-fkart IN r_cancl.
        wa_dt-kwert_cm = wa_dt-kwert_val * -1.
        wa_dt-fkimg_cm = wa_hd-fkimg * -1.
        wa_dt-cntax = wa_hd-mwsbp * -1.
        wa_dt-kwert = wa_dt-kwert.
        wa_dt-netsls = ( wa_dt-kwert_cm + wa_dt-cntax
                         - wa_dt-kwert ) * -1.
      ELSE.
        wa_dt-kwert_cm = wa_dt-kwert_val.
        wa_dt-fkimg_cm = wa_hd-fkimg.
        wa_dt-kwert = wa_dt-kwert.   " * -1.
        IF wa_hd-fkart = 'ZR02'.
          wa_dt-cntax  = wa_hd-mwsbp * -1.
        ELSE.
          wa_dt-cntax  = wa_hd-mwsbp.
        ENDIF.
        wa_dt-netsls = ( wa_dt-kwert_cm + wa_hd-mwsbp
                         + wa_dt-kwert ) * -1.
*        wa_dt-netsls = ( wa_dt-kwert_cm + wa_dt-cntax
*                         + wa_dt-kwert ) * -1.    "- wa_dt-kwert ) * -1.
      ENDIF.
    ENDIF.

* coding below, if using KBETR
**    IF wa_dt-vgtyp = 'J' OR wa_dt-vgtyp = 'L'.
**      IF wa_hd-fkart IN r_cancl.
**        wa_dt-kbetr_iv = wa_dt-kbetr * -1.
**        wa_dt-fkimg_iv = wa_hd-fkimg * -1.
**        wa_dt-tax = wa_hd-mwsbp * -1.
***        wa_dt-netsls = wa_dt-kbetr_iv + wa_dt-tax.
**      ELSE.
**        wa_dt-kbetr_iv = wa_dt-kbetr.
**        wa_dt-fkimg_iv = wa_hd-fkimg.
**        wa_dt-tax = wa_hd-mwsbp.
**        wa_dt-kwert = wa_dt-kwert * -1.
***        wa_dt-netsls = wa_dt-kbetr_iv + wa_dt-tax - wa_dt-kwert.
**      ENDIF.
**    ELSEIF wa_dt-vgtyp = 'T' OR wa_dt-vgtyp = 'K'.
**      IF wa_hd-fkart IN r_cancl.
**        wa_dt-kbetr_cm = wa_dt-kbetr * -1.
**        wa_dt-fkimg_cm = wa_hd-fkimg * -1.
**        wa_dt-cntax = wa_hd-mwsbp * -1.
***        wa_dt-netsls = wa_dt-kbetr_cm + wa_dt-cntax.
**      ELSE.
**        wa_dt-kbetr_cm = wa_dt-kbetr.
**        wa_dt-fkimg_cm = wa_hd-fkimg.
**        wa_dt-cntax = wa_hd-mwsbp.
**        wa_dt-kwert = wa_dt-kwert * -1.
***        wa_dt-netsls = wa_dt-kbetr_cm + wa_dt-cntax - wa_dt-kwert.
**      ENDIF.
**    ENDIF.
**
*** coding below, if using BRTWR
**    IF wa_dt-vgtyp = 'J' OR wa_dt-vgtyp = 'L'.
**      IF wa_hd-fkart IN r_cancl.
**        wa_dt-brtwr_iv = wa_hd-brtwr * -1.
**        wa_dt-fkimg_iv = wa_hd-fkimg * -1.
**        wa_dt-tax = wa_hd-mwsbp * -1.
***        wa_dt-NetSls = wa_dt-brtwr_iv + wa_dt-tax.
**      ELSE.
**        wa_dt-brtwr_iv = wa_hd-brtwr.
**        wa_dt-fkimg_iv = wa_hd-fkimg.
**        wa_dt-tax = wa_hd-mwsbp.
**        wa_dt-kwert = wa_dt-kwert * -1.
***        wa_dt-NetSls = wa_dt-brtwr_iv + wa_dt-tax - wa_dt-kwert.
**      ENDIF.
**    ELSEIF wa_dt-vgtyp = 'T' OR wa_dt-vgtyp = 'K'.
**      IF wa_hd-fkart IN r_cancl.
**        wa_dt-brtwr_cm = wa_hd-brtwr * -1.
**        wa_dt-fkimg_cm = wa_hd-fkimg * -1.
**        wa_dt-cntax = wa_hd-mwsbp * -1.
***        wa_dt-NetSls = wa_dt-brtwr_cm + wa_dt-cntax.
**      ELSE.
**        wa_dt-brtwr_cm = wa_hd-brtwr.
**        wa_dt-fkimg_cm = wa_hd-fkimg.
**        wa_dt-cntax = wa_hd-mwsbp.
**        wa_dt-kwert = wa_dt-kwert * -1.
***        wa_dt-NetSls = wa_dt-brtwr_cm + wa_dt-cntax - wa_dt-kwert.
**      ENDIF.
**    ENDIF.

*    wa_dt-grosls = wa_dt-brtwr_iv - wa_dt-brtwr_cm.
    wa_dt-grosls = wa_dt-kwert_iv - wa_dt-kwert_cm.


*-modify-start by idub 20070115
    READ TABLE i_komernr INTO wa_komernr
    WITH KEY vbeln = wa_hd-vbeln
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      CONCATENATE wa_komernr-invo1 '-' wa_komernr-invo2 '/'
                  wa_komernr-gjahr
                  INTO wa_dt-komernr.
    ELSE.
      wa_dt-fakno = space.
    ENDIF.
*-modify-end by idub 20070115

    wa_dt-vgbel = wa_hd-vgbel.

    APPEND wa_dt TO i_dt.

    CLEAR: wa_dt,
           wa_konvsum,
           wa_cust.

  ENDLOOP.


ENDFORM.                    "f_get_data


*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.

**  t_main_tmp[] = t_main[].
**  ASSIGN t_main_tmp TO <fs_table>.
  PERFORM f_alv TABLES i_dt.

ENDFORM.                    "f_print_data


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
  PERFORM f_build_layout     USING   d_layout.
  PERFORM f_build_sortfield  USING   t_alv_isort[].
  PERFORM f_build_event      TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print      USING   d_print.
  PERFORM f_alv_variant_exist USING   p_vari
                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK        = ' '
*     I_BYPASSING_BUFFER       =
*     I_BUFFER_ACTIVE          = ' '
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
*     I_STRUCTURE_NAME         =
      is_layout                = d_layout
      it_fieldcat              = t_alv_fieldcat[]
*     IT_EXCLUDING             =
*     IT_SPECIAL_GROUPS        =
      it_sort                  = t_alv_isort[]
*     IT_FILTER                =
*     IS_SEL_HIDE              =
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = d_alv_variant
      it_events                = t_alv_event[]
      it_event_exit            = t_event_exit[]
      is_print                 = d_print
*     IS_REPREP_ID             =
*     I_SCREEN_START_COLUMN    = 0
*     I_SCREEN_START_LINE      = 0
*     I_SCREEN_END_COLUMN      = 0
*     I_SCREEN_END_LINE        = 0
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
*     ES_EXIT_CAUSED_BY_USER   =
    TABLES
      t_outtab                 = ft_report
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.





ENDFORM.                    "f_alv


*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.

  REFRESH: t_alv_fieldcat.

**  PERFORM f_fieldcatg USING ft_report:
**    'WERKS' 'T001W' 'WERKS' '' '' '' '' '' '' '' '' '' '' '',
**    'NAME1' 'T001W' 'NAME1' '' '' '' '' '' '' '' '' '' '' '',
**    'MATNR' 'MARA' 'MATNR' '' '' '' '' '' '' '' '' '' '' '',
**    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '',
**    'TOT'   'PBED' 'PLNMG' '' '' 'Total' 'X' '' '' '' '' '' '' ''.

  PERFORM f_fieldcatg USING ft_report:
    'KUNAG' 'VBRK' '' 'X' '18' 'Sold To Party No' '' '' '' '' '' '' ''
'',
    'NAME1' 'KNA1' '' '' '' 'Sold To Party Name' '' '' '' '' '' '' '' ''
,
    'KUNRG' 'VBRK' '' '' '18' 'Bill To Party No' '' '' '' '' '' '' '' ''
,
    'NAME2' 'KNA1' '' '' '' 'Bill To Party Name' '' '' '' '' '' '' '' ''
,
    'FAKNO' '' '' '' '18' 'No Seri Pajak' '' '' '' '' '' '' ''
'',
    'VBELN' 'VBRP' 'VBELN' '' '' '' '' 'X' '' '' '' '' '' ''.

  IF p_vkorg = '8010'.
    PERFORM f_fieldcatg USING ft_report:
      'VGBEL' 'VBRP' 'VGBEL' '' '' 'DN' '' 'X' '' '' '' '' '' ''.
  ENDIF.

  PERFORM f_fieldcatg USING ft_report:
    'KOMERNR' '' '' '' '16' 'No Fkt Penjualan' '' '' '' '' '' '' ''
'',
    'BSART' 'EKKO' 'BSART' '' '' 'POTy' '' '' '' '' '' '' '' '',
    'AUART' 'VBAK' 'AUART' '' '' 'SOTy' '' '' '' '' '' '' '' '',
    'ABPER' 'S603' 'SPMON' '' '' '' '' '' '' '' '' '' '' '',
    'FKDAT' 'VBRK' 'FKDAT' '' '' '' '' '' '' '' '' '' '' '',
    'VKBUR' 'VBRP' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '',
    'MATKL' '' '' '' '15' 'Material Group' '' '' '' '' '' '' '' '',
    'MATNR' '' '' '' '15' 'Material No' '' '' '' '' '' '' '' '',
    'ARKTX' '' '' '' '40' 'Material Description' '' '' '' '' '' '' '' ''
,
    'WAERK' 'VBRK' 'WAERK' '' '' '' '' '' '' '' '' '' '' '',
*    'BRTWR_IV' '' '' '' '20' 'Gross Inv Sls' 'X' '' ''
*'' '' 'WAERK' '' '',
*    'BRTWR_CM' '' '' '' '20' 'Gross Credit Memo' 'X' '' ''
*'' '' 'WAERK' '' '',
*    'KBETR_IV' '' '' '' '20' 'Gross IV - KBETR' 'X' '' ''
*'' '' 'WAERK' '' '',
*    'KBETR_CM' '' '' '' '20' 'Gross CM - KBETR' 'X' '' ''
*'' '' 'WAERK' '' '',
    'KWERT_IV' '' '' '' '20' 'Gross Inv Sales' 'X' '' ''
'' '' 'WAERK' '' '',
    'KWERT_CM' '' '' '' '20' 'Gross Credit Memo' 'X' '' ''
'' '' 'WAERK' '' '',
    'GROSLS' '' '' '' '20' 'Gross Sales' 'X' '' ''
'' '' 'WAERK' '' '',
    'NETSLS' '' '' '' '20' 'Net Sales' 'X' '' ''
'' '' 'WAERK' '' '',
    'FKIMG_IV' '' '' '' '20' 'Invoiced QTY' 'X' '' '' '' '' '' 'VRKME'
 '',
    'FKIMG_CM' '' '' '' '20' 'Credit Memo QTY' 'X' '' '' '' '' ''
 'VRKME' '',
    'VRKME' 'VBRP' 'VRKME' '' '' '' '' '' '' '' '' '' '' '',
    'TAX' '' '' '' '20' 'TAX' 'X' '' '' '' '' 'WAERK' '' '',
    'ZTX1' '' '' '' '20' 'VAT' 'X' '' '' '' '' 'WAERK' '' '',
    'ZTX5' '' '' '' '20' 'PPh22' 'X' '' '' '' '' 'WAERK' '' '',
    'CNTAX' '' '' '' '20' 'CN TAX' 'X' '' '' '' '' 'WAERK' '' '',
    'KWERT' '' '' '' '' 'Discount' 'X' '' '' '' '' 'WAERK' '' '',
    'ZN01' '' '' '' '' 'NSP' 'X' '' '' '' '' 'WAERK' '' '',
    'ZDB3' '' '' '' '' 'Direct Margin' 'X' '' '' '' '' 'WAERK' '' '',
    'ZDB4' '' '' '' '' 'Suppl Margin' 'X' '' '' '' '' 'WAERK' '' ''.


*    'BRTWR' 'VBRP' 'BRTWR' '' '' '' 'X' '' '' 'IDR' '' '' '' '',
*    'ABPER' 'BSEG' 'ABPER' '' '' '' '' '' '' '' '' '' '' '',
*    'FKIMG' 'VBRP' 'FKIMG' '' '' '' 'X' '' '' '' '' '' 'VRKME' '',
*    'KNUMV' 'VBRK' 'KNUMV' '' '' '' '' '' '' '' '' '' '' '',
*    'POSNR' 'VBRP' 'POSNR' '' '' '' '' '' '' '' '' '' '' '',
*    'VGTYP' 'VBRP' 'VGTYP' '' '' '' '' '' '' '' '' '' '' '',


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
FORM f_fieldcatg USING    VALUE(fu_types)
                          VALUE(fu_fname)
                          VALUE(fu_reftb)
                          VALUE(fu_refld)
                          VALUE(fu_noout)
                          VALUE(fu_outln)
                          VALUE(fu_fltxt)
                          VALUE(fu_dosum)
                          VALUE(fu_hotsp)
                          VALUE(fu_dec)
                          VALUE(fu_waers)
                          VALUE(fu_meins)
                          VALUE(fu_waers_f)
                          VALUE(fu_meins_f)
                          VALUE(fu_checkbox).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.
  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname       = fu_types.
  ld_fieldcat-fieldname     = fu_fname.
  ld_fieldcat-ref_tabname   = fu_reftb.
  ld_fieldcat-ref_fieldname = fu_refld.
  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-outputlen     = fu_outln.
  ld_fieldcat-seltext_l     = fu_fltxt.
  ld_fieldcat-seltext_m     = fu_fltxt.
  ld_fieldcat-seltext_s     = fu_fltxt.
  ld_fieldcat-reptext_ddic  = fu_fltxt.
  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-do_sum        = fu_dosum.
  ld_fieldcat-hotspot       = fu_hotsp.
  ld_fieldcat-decimals_out  = fu_dec.
  ld_fieldcat-currency    = fu_waers.
  ld_fieldcat-quantity      = fu_meins.
  ld_fieldcat-qfieldname    = fu_meins_f.
  ld_fieldcat-cfieldname    = fu_waers_f.
  ld_fieldcat-checkbox      = fu_checkbox.
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

*  CLEAR ft_events.
*  ft_events-name = slis_ev_end_of_page.
*  ft_events-form = 'F_END_OF_PAGE'.
*  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_before_line_output.
*  ft_events-form = 'F_BEFORE_LINE_OUTPUT'.
*  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_after_line_output.
*  ft_events-form = 'F_AFTER_LINE_OUTPUT'.
*  APPEND ft_events.
*
*  CLEAR ft_events.
*  ft_events-name = slis_ev_subtotal_text.
*  ft_events-form = 'F_SUBTOTAL'.
*  APPEND ft_events.





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
* fu_layout-f2code             = '&ETA'.
* fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-info_fieldname     = 'INFO'.

ENDFORM.                    "f_build_layout


*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_PRINT                                                      *
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos = 'X'.
  fu_print-no_print_selinfos  = 'X'.
  fu_print-no_coverpage       = 'X'.
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
  ld_sort-fieldname = 'KUNAG'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
*  CLEAR ld_sort.
*  ld_sort-fieldname = 'VERSB'.
*  ld_sort-up        = 'X'.
*  APPEND ld_sort TO fu_sort.

ENDFORM.                    "f_build_sortfield



*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.
  DATA: ld_tgl(50),
        ld_from(10),
        ld_to(10).

  WRITE: s_fkdat-low TO ld_from,
         s_fkdat-high TO ld_to.

  IF s_fkdat-low IS INITIAL AND s_fkdat-high IS INITIAL.
    CLEAR ld_tgl.
  ENDIF.
  IF s_fkdat-low IS INITIAL AND NOT s_fkdat-high IS INITIAL.
    CONCATENATE 'FROM' ld_to 'TO' ld_to INTO ld_tgl
            SEPARATED BY space.
  ENDIF.
  IF NOT s_fkdat-low IS INITIAL AND s_fkdat-high IS INITIAL.
    CONCATENATE 'FROM' ld_from 'TO' ld_from INTO ld_tgl
            SEPARATED BY space.
  ENDIF.
  IF NOT s_fkdat-low IS INITIAL AND NOT s_fkdat-high IS INITIAL.
    CONCATENATE 'FROM' ld_from 'TO' ld_to INTO ld_tgl
              SEPARATED BY space.
  ENDIF.
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ld_tgl.
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
* refresh:

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
  SET PF-STATUS 'STANDARD'.

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
*&---------------------------------------------------------------------*
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data.

ENDFORM.                    " f_validate_data



*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.

  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  fu_selfield-refresh = 'X'.

  CASE fu_ucomm.
    WHEN '&POS'.
      PERFORM f_post_entries.

    WHEN  'FEHL' OR '&IC1'.
      READ TABLE i_dt INTO wa_dt INDEX fu_selfield-tabindex.

      IF fu_selfield-tabindex NE 0.
        CASE fu_selfield-fieldname.
          WHEN 'VBELN'.
            SET PARAMETER ID 'VF' FIELD wa_dt-vbeln.
            CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
          WHEN 'VGBEL'.
            SET PARAMETER ID 'VL' FIELD wa_dt-vgbel.
            CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
        ENDCASE.
      ELSE.
        MESSAGE e000(zf).
      ENDIF.
  ENDCASE.

ENDFORM.                    "f_user_command
*&---------------------------------------------------------------------*
*&      Form  f_post_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_entries.

ENDFORM.                    " f_post_entries





*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_f4_for_variant_alv CHANGING fc_variant.

  DATA: ld_variant LIKE disvariant.
  DATA: ld_repid   LIKE sy-repid.
  ld_repid = sy-repid.
  ld_variant-report   = ld_repid.
  ld_variant-username = sy-uname.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = ld_variant
      i_save     = 'A'
    IMPORTING
      es_variant = ld_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    fc_variant = ld_variant-variant.
  ENDIF.




ENDFORM.                    " F_F4_FOR_VARIANT_ALV


*data: gs_lineinfo type kkblo_lineinfo.
FORM f_after_line_output USING lineinfo TYPE slis_lineinfo.
  BREAK-POINT.
ENDFORM.                    "f_after_line_output

*&---------------------------------------------------------------------*
*&      Form  f_format_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_BUDAT  text
*      <--FC_BUDAT  text
*----------------------------------------------------------------------*
FORM f_format_date USING    fu_budat
                   CHANGING fc_budat.

  READ TABLE t_user INDEX 1.
  CASE t_user-datfm.
    WHEN 'DD.MM.YYYY'.
*{   REPLACE        P01K900131                                        1
*\      CONCATENATE fu_budat+6(2) fu_budat+4(2) fu_budat+(4)
*\                  INTO fc_budat.
* start changed by saan 20070326
      CONCATENATE fu_budat+6(2) fu_budat+4(2) fu_budat+0(4)
                  INTO fc_budat.
* end changed by saan 20070326
*}   REPLACE
    WHEN 'MM/DD/YYYY' OR 'MM-DD-YYYY'.
*{   REPLACE        P01K900131                                        2
*\      CONCATENATE fu_budat+4(2) fu_budat+6(2) fu_budat+(4)
*\                  INTO fc_budat.
* start changed by saan 20070326
      CONCATENATE fu_budat+4(2) fu_budat+6(2) fu_budat+0(4)
                  INTO fc_budat.
* end changed by saan 20070326
*}   REPLACE
    WHEN 'YYYY.MM.DD' OR 'YYYY/MM/DD' OR 'YYYY-MM-DD'.
      CONCATENATE fu_budat+(4) fu_budat+4(2) fu_budat+6(2)
                  INTO fc_budat.
  ENDCASE.

ENDFORM.                    " f_format_date

*&---------------------------------------------------------------------*
*&      Form  F_GET_PO_TYPE
*&---------------------------------------------------------------------*
FORM f_get_po_type  USING    fu_flag fu_xblnr fu_posnr
                    CHANGING fc_ebeln.
  CASE fu_flag.
    WHEN '1'.
      SELECT SINGLE ebeln
       FROM ekbe
       INTO (wa_hd-ebeln)
       WHERE xblnr EQ wa_hd-xblnr.

    WHEN '2'.
      SELECT SINGLE aubel vgbel
        FROM vbrp
        INTO (wa_hd-ebeln, wa_hd-vgbel)
        WHERE vbeln = fu_xblnr
          AND posnr = fu_posnr.
  ENDCASE.

  SELECT SINGLE bsart FROM ekko
  INTO (wa_dt-bsart)
  WHERE ebeln EQ wa_hd-ebeln AND
        bsart IN s_bsart.
ENDFORM.                    " F_GET_PO_TYPE
