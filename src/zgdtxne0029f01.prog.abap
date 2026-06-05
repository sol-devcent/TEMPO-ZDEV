*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNE0029F01                                           *
*----------------------------------------------------------------------*



FORM f_initialization.
  p_masatx = sy-datum(6).
  p_gjahr = sy-datum(4).
  p_monat = sy-datum+4(2).
ENDFORM.                    "f_initialization

*---------------------------------------------------------------------*
*       FORM f_select_period                                          *
*---------------------------------------------------------------------*
FORM f_select_period.
  DATA: ld_closedat LIKE zgdtxdt0004-closedat,
* commented it out by pendi on 9/6/2003, ld_gsber is never used
* in this routine
*        ld_gsber    LIKE zGDTXdt0004-gsber,
        ld_masatx   LIKE p_masatx.

  CLEAR: ld_closedat, ld_masatx.
  SELECT SINGLE masatx closedat FROM zgdtxdt0004
                       INTO (ld_masatx, ld_closedat)
*                       WHERE vkorg    = p_bukrs AND
                       WHERE bukrs    = p_bukrs AND
* changed by pendi on 9/6/2003
*                             gsber    = p_gsber AND
                             brnch    = p_brnch AND
                             masatx   = p_masatx.

  IF sy-subrc NE 0.
    MESSAGE e000(zab) WITH 'Masa pajak belum dibuka'.
  ENDIF.

  IF NOT ld_closedat IS INITIAL.
    MESSAGE e000(zab) WITH 'Masa Pajak sudah ditutup'.
  ENDIF.

  IF p_mspjk(6) NE p_masatx.
    MESSAGE e000(zab) WITH 'Masa Pajak tidak Sesuai'.
  ENDIF.

ENDFORM.                    " F_SELECT_PERIOD

*&---------------------------------------------------------------------*
*&      Form  F_SELECT_OUTPUT
*&---------------------------------------------------------------------*
FORM f_select_output.

*  LOOP AT SCREEN.
*    IF screen-name CS 'P_MASATX'.
*      screen-input = 0.
*    ELSE.
*      screen-input = 1.
*    ENDIF.
*    MODIFY SCREEN.
*  ENDLOOP.

ENDFORM.                    " F_SELECT_OUTPUT

*---------------------------------------------------------------------*
*       FORM f_check_gjahr                                            *
*---------------------------------------------------------------------*
FORM f_check_gjahr.
  IF NOT s_belnr[] IS INITIAL.
    IF p_gjahr IS INITIAL.
      MESSAGE e000(zab) WITH 'Make an entry in all required fields'.
    ENDIF.
  ENDIF.
ENDFORM.                    "f_check_gjahr

*---------------------------------------------------------------------*
*       FORM f_check_gjahr                                            *
*---------------------------------------------------------------------*
FORM f_check_monat.
  IF NOT s_belnr[] IS INITIAL.
    IF p_monat IS INITIAL.
      MESSAGE e000(zab) WITH 'Make an entry in all required fields'.
    ENDIF.
  ENDIF.
ENDFORM.                    "f_check_monat

*---------------------------------------------------------------------*
*       FORM f_check_blart                                            *
*---------------------------------------------------------------------*
*       blart not equal to 'RV'
* commented out by Pendi on 10/6/2003
* This routine is not used since 'RV' is no more restricted doc type
*---------------------------------------------------------------------*
*FORM f_check_blart.
*  IF p_blart EQ 'RV'.
*    MESSAGE e000(zab) WITH 'Wrong input'.
*  ENDIF.
*ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_check_bukrs                                            *
*---------------------------------------------------------------------*
*       make sure user enter a valid company code and put it in wa    *
*---------------------------------------------------------------------*
FORM f_check_bukrs.
*-- taken from f_init_data
  SELECT SINGLE butxt
    FROM t001
    INTO t001-butxt
    WHERE bukrs = p_bukrs.
  IF sy-subrc <> 0.
    MESSAGE e000(zab) WITH 'Company code does not exist!'.
  ENDIF.
ENDFORM.                    "f_check_bukrs

*---------------------------------------------------------------------*
*       FORM f_check_brnch                                            *
*---------------------------------------------------------------------*
*       make sure user enter a valid branch code                      *
*---------------------------------------------------------------------*
FORM f_check_brnch.
* Read table branch
  SELECT SINGLE bdesc
         INTO d_cabtxt
         FROM zgdtxdt0101
         WHERE brnch EQ p_brnch AND
               bukrs EQ p_bukrs.
  IF sy-subrc <> 0.
    MESSAGE e000(zab) WITH 'Branch' p_brnch
                           'is not defined in company' p_bukrs.
  ENDIF.
ENDFORM.                    "f_check_brnch

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data.
  DATA lt_05 LIKE zgdtxdt0005 OCCURS 0 WITH HEADER LINE.
  DATA ld_blart LIKE zgdtxdt0104-blart.
  DATA ld_hkont LIKE zgdtxdt0104-hkont.

***added for Tempo
  PERFORM f_get_open_period USING p_brnch.
***end of Tempo addition

  d_alv_repid = sy-repid.
* commented by pendi on 9/6/2003, it's never used
*  d_alv_stats = 'ALV'.
  d_alv_ucomm = 'F_USER_COMMAND'.

*--- move this part to f_check_bukrs
*  SELECT SINGLE butxt
*    FROM t001
*    INTO t001-butxt
*    WHERE bukrs = p_bukrs.

*--- move and change this part to f_check_brnch
*  SELECT SINGLE gtext
*    FROM tgsbt
*    INTO tgsbt-gtext
*    WHERE spras = sy-langu
*      AND gsber = p_gsber.


* changed by pendi on 9/6/2003
*  data: ld_gsber like bseg-gsber.
*  concatenate p_gsber(1) '000' into ld_gsber.

  SELECT masafrom fpone fptwo objrange coretax
    FROM zgdtxdt0005
    INTO CORRESPONDING FIELDS OF TABLE lt_05
*    WHERE vkorg = p_bukrs
*      AND gsber = p_gsber
*      AND gsber = ld_gsber
* changed by pendi on 9/6/2003
     WHERE bukrs = p_bukrs
       AND brnch = p_brnch
       AND masafrom LT p_mspjk.

  SORT lt_05 BY masafrom DESCENDING.

  READ TABLE lt_05 INDEX 1.

  dl_fpone = lt_05-fpone.
  dl_fptwo = lt_05-fptwo.
  dl_objrange = lt_05-objrange.
  dl_coretax = lt_05-coretax.

* changed by pendi on 9/6/2003
*  CONCATENATE sy-repid p_bukrs p_gsber INTO d_lock.
  CONCATENATE sy-repid p_bukrs p_brnch INTO d_lock.

*--added by Pendi on 11/6/2003
*--get all the document type and GL/Account from ZGDTXDT0104 table
  CLEAR: r_hkont, r_blart.
  REFRESH: r_hkont, r_blart.
  r_hkont-sign = 'I'. r_blart-sign = 'I'.
  r_hkont-option = 'EQ'. r_blart-option = 'EQ'.
***modified by Rahmadi
  SELECT *  "hkont blart
*         INTO TABLE t_zGDTXdt0104
         FROM zgdtxdt0104
         WHERE bukrs = p_bukrs
         AND   brnch = p_brnch.
    IF sy-subrc <> 0.
      MESSAGE i000(zab) WITH 'Could not find GL/Account and Doc. Type'
                            'Please maintain the zGDTXdt0104 table!'.
    ELSE.
      r_hkont-low = zgdtxdt0104-hkont.
      APPEND r_hkont.
      r_blart-low = zgdtxdt0104-blart.
      APPEND r_blart.
    ENDIF.
  ENDSELECT.
***end of modification

***added for Tempo --- TNT only, materai GL Account
  IF p_bukrs = d_tnt_bukrs.
    CLEAR: r_hkont_mt, r_blart_mt, ld_hkont, ld_blart.
    REFRESH: r_hkont_mt, r_blart_mt.
    r_hkont_mt-sign = 'I'. r_blart_mt-sign = 'I'.
    r_hkont_mt-option = 'EQ'. r_blart_mt-option = 'EQ'.

    SELECT hkont_mt blart
           INTO (ld_hkont, ld_blart)
           FROM zgdfidt0001
           WHERE bukrs = p_bukrs.
      IF sy-subrc = 0.
        r_hkont_mt-low = ld_hkont.
        APPEND r_hkont_mt.
        r_blart_mt-low = ld_blart.
        APPEND r_blart_mt.
      ENDIF.
    ENDSELECT.
  ENDIF.
***end of Tempo addition

  SELECT SINGLE *
    FROM zproject
    INTO CORRESPONDING FIELDS OF gs_dpp
    WHERE name = 'DPP12'.

  PERFORM f_coretax_validate.

ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_CUSTOM_DATA
*&---------------------------------------------------------------------*
FORM f_get_custom_data.
  DATA:
    lt_03 LIKE zgdtxdt0003 OCCURS 0 WITH HEADER LINE,
    lt_02 LIKE zgdtxdt0002 OCCURS 0 WITH HEADER LINE.

* select semua field krn cenderung hampir semua field bisa dirubah
* di program ini.
***changed for Tempo
***no need to select from this table if processing FP sederhana
* transport DEVK927362
*  IF p_sedh IS INITIAL.    "FP standard
  SELECT *
    FROM zgdtxdt0003
    INTO TABLE lt_03
* changed by pendi on 9/6/2003
*    WHERE gsber = p_gsber
*      AND spart = '99'
     WHERE brnch = p_brnch
***modified by Rahmadi
      AND busln = p_busln           " non-trade: BUSLN = '99'
***changed for Tempo
*      AND masatx = p_masatx.
      AND masatx IN r_per.
***end of Tempo changes

*  SORT lt_03 BY vkorg gsber spart fakturno masatx batal returcount.
  SORT lt_03 BY bukrs brnch busln fakturno masatx batal returcount.

  IF NOT lt_03[] IS INITIAL.
    SELECT *
      FROM zgdtxdt0002
      INTO TABLE lt_02
      FOR ALL ENTRIES IN lt_03
* changed by pendi on 9/6/2003
*      WHERE vkorg = lt_03-vkorg
*        AND gsber = p_gsber
*        AND spart = lt_03-spart
      WHERE bukrs = lt_03-bukrs
        AND brnch = p_brnch
        AND busln = lt_03-busln
        AND fakturno = lt_03-fakturno
***changed for Tempo
*        AND masatx = p_masatx.
        AND masatx IN r_per.
***end of Tempo changes
  ENDIF.
*  ELSE.    "FP Sederhana
*    SELECT *
*      FROM zgdtxdt0002
*      INTO TABLE lt_02
*      WHERE bukrs = p_bukrs
*        AND brnch = p_brnch
*        AND busln = p_busln
*        AND masatx IN r_per
*        AND fakturno = ''.
*  ENDIF.
***end of Tempo changes

* changed by pendi on 9/6/2003
*  SORT lt_02 BY vkorg gsber spart vbeln posnr gjahr fakturno.
  SORT lt_02 BY bukrs brnch busln vbeln posnr gjahr fakturno.


  REFRESH: t_data.
  LOOP AT lt_02.
* changed by pendi on 9/6/2003
*    READ TABLE lt_03 WITH KEY vkorg = lt_02-vkorg
*                              gsber = p_gsber
*                              spart = lt_02-spart
****changed for Tempo
****only read this table if processing FP standard
*    IF p_sedh IS INITIAL.
    READ TABLE lt_03 WITH KEY bukrs = lt_02-bukrs
                              brnch = p_brnch
                              busln = lt_02-busln
                              fakturno = lt_02-fakturno
                              BINARY SEARCH.
*    ENDIF.
****end of Tempo changes

    MOVE-CORRESPONDING lt_02 TO t_data.

****changed for Tempo
****only read this table if processing FP standard
* transport DEVK927362
*    IF p_sedh IS INITIAL.
    MOVE-CORRESPONDING lt_03 TO t_data.
    IF t_data-nocoretax IS INITIAL.
      t_data-nocoretax = lt_02-fakturno.
    ENDIF.
*    ENDIF.
****end of Tempo changes

    MOVE 'T' TO t_data-table.
    MOVE '1' TO t_data-icon.

    IF lt_02-fkart = d_fkart_arnr.     "'ARNR'.
      MOVE 'R' TO t_data-f.
    ELSEIF lt_02-fkart = d_fkart_arnt. "'ARNT'.
      MOVE 'N' TO t_data-f.
    ENDIF.
    APPEND t_data.
  ENDLOOP.

  SORT t_data BY belnr gjahr.

ENDFORM.                    " F_GET_CUSTOM_DATA

*---------------------------------------------------------------------*
*       FORM f_get_sap_data                                           *
*---------------------------------------------------------------------*
FORM f_get_sap_data.

  DATA ld_from LIKE sy-tabix.
  DATA ld_to LIKE sy-tabix.
  DATA ld_masatx LIKE zgdtxdt0003-masatx.
  DATA ld_fakdat LIKE zgdtxdt0003-fakdat.
  DATA ld_gjahr LIKE bkpf-gjahr.

  RANGES: lr_belnr FOR bseg-belnr.

  DATA : BEGIN OF lt_bsec OCCURS 0,
           bukrs LIKE bsec-bukrs,
           belnr LIKE bsec-belnr,
           gjahr LIKE bsec-gjahr,
           buzei LIKE bsec-buzei,
           name1 LIKE bsec-name1,
           stras LIKE bsec-stras,
           stcd1 LIKE bsec-stcd1,
           stcd2 LIKE bsec-stcd2,
           bkref LIKE bsec-bkref,
         END OF lt_bsec.

  DATA: BEGIN OF lt_bkpf OCCURS 0,
          bukrs LIKE bkpf-bukrs,
          belnr LIKE bkpf-belnr,
          gjahr LIKE bkpf-gjahr,
          budat LIKE bkpf-budat,
          stblg LIKE bkpf-stblg,
          waers LIKE bkpf-waers,
          kursf LIKE bkpf-kursf,
        END OF lt_bkpf,

        BEGIN OF lt_02 OCCURS 0,
          vbeln    LIKE zgdtxdt0002-vbeln,
          gjahr    LIKE zgdtxdt0002-gjahr,
          fakturno LIKE zgdtxdt0002-fakturno,
        END OF lt_02.

  DATA    BEGIN OF lt_bseg OCCURS 0.
***modified by Rahmadi
  INCLUDE STRUCTURE zgdtxst0008.
*          bukrs LIKE bseg-bukrs,
*          belnr LIKE bseg-belnr,
*          gjahr LIKE bseg-gjahr,
*          buzei LIKE bseg-buzei,
*          shkzg LIKE bseg-shkzg,
*          bschl LIKE bseg-bschl,
*          kunnr LIKE bseg-kunnr,
*          wrbtr LIKE bseg-wrbtr,
*          sgtxt LIKE bseg-sgtxt,
*          hkont LIKE bseg-hkont,
*          gsber LIKE bseg-gsber,
*          brnch LIKE zGDTXdt0101-brnch,
***end of modification
  DATA    END OF lt_bseg.

  DATA lt_belnr1 LIKE lt_bseg OCCURS 0 WITH HEADER LINE.

*--added by pendi to get the customer information
*--where posting keys start with 0
***modified by Rahmadi
*  begin of lt_bseg2 occurs 0,
*    bukrs like bseg-bukrs,
*    belnr like bseg-belnr,
*    gjahr like bseg-gjahr,
*    buzei like bseg-buzei,
*    shkzg like bseg-shkzg,
*    bschl like bseg-bschl,
*    kunnr like bseg-kunnr,
*    lifnr like bseg-lifnr,
*    wrbtr like bseg-wrbtr,
*    sgtxt like bseg-sgtxt,
*    hkont like bseg-hkont,
*    gsber like bseg-gsber,
*    brnch like zGDTXdt0101-brnch,
*  end of lt_bseg2,
  DATA lt_bseg2 LIKE lt_bseg OCCURS 0 WITH HEADER LINE.
***end of modification

*vendor information
  DATA: BEGIN OF lt_lfa1 OCCURS 0,
          lifnr LIKE lfa1-lifnr,
          name1 LIKE lfa1-name1,
          stceg LIKE lfa1-stceg,
          xcpdk LIKE lfa1-xcpdk,
          stcd1 LIKE lfa1-stcd1,
          stras LIKE lfa1-stras,
          ort01 LIKE lfa1-ort01,
          pstlz LIKE lfa1-pstlz,
          anred LIKE lfa1-anred,
          adrnr LIKE lfa1-adrnr,
        END OF lt_lfa1,
*--end of addition

        BEGIN OF lt_kna1 OCCURS 0,
          kunnr LIKE kna1-kunnr,
          name1 LIKE kna1-name1,
          stceg LIKE kna1-stceg,
          xcpdk LIKE kna1-xcpdk,
          stcd1 LIKE kna1-stcd1,
          stras LIKE kna1-stras,
          ort01 LIKE kna1-ort01,
          pstlz LIKE kna1-pstlz,
          anred LIKE kna1-anred,
          adrnr LIKE kna1-adrnr,
        END OF lt_kna1,

        ls_belnr LIKE s_belnr OCCURS 0 WITH HEADER LINE.

  DATA lt_adrnr LIKE lt_kna1 OCCURS 0 WITH HEADER LINE.
  DATA lt_zterm LIKE lt_bseg OCCURS 1 WITH HEADER LINE.

  DATA lt_bseg_mt LIKE lt_bseg OCCURS 0 WITH HEADER LINE.

  BREAK bcrmd.

  CHECK NOT s_belnr[] IS INITIAL.

  SELECT bukrs belnr gjahr budat stblg waers kursf
    FROM bkpf
    INTO TABLE lt_bkpf
*--added by Pendi on 11/6/2003
***modified by Rahmadi
*    FOR ALL ENTRIES IN t_zGDTXdt0104
***end of modification
    WHERE bukrs = p_bukrs
      AND belnr IN s_belnr
*      AND blart = p_blart
***modified by Rahmadi
*      AND blart = t_zGDTXdt0104-blart
      AND blart IN r_blart
***end of modification
      AND bstat EQ space
      AND stblg EQ space
      AND gjahr = p_gjahr
      AND monat = p_monat.

*One time Customer
  SELECT bukrs
         belnr
         gjahr
         buzei
         name1
         stras
         stcd1
         stcd2
         bkref
   FROM bsec
   INTO TABLE lt_bsec
   WHERE bukrs = p_bukrs AND
         belnr IN s_belnr AND
         gjahr = p_gjahr.

  LOOP AT lt_bkpf.
    READ TABLE t_data WITH KEY belnr = lt_bkpf-belnr
                               gjahr = lt_bkpf-gjahr
                               BINARY SEARCH.
* changed by pendi on 11/6/2003
*    CHECK sy-subrc = 0.
*    DELETE lt_bkpf.
    IF sy-subrc = 0.
      DELETE lt_bkpf.
      CONTINUE.
    ENDIF.
*add the range if it is not deleted
    m_s ls_belnr lt_bkpf-belnr.
  ENDLOOP.

  CHECK NOT lt_bkpf[] IS INITIAL.

*changed by pendi, move it up there
*  LOOP AT lt_bkpf.
*    m_s ls_belnr lt_bkpf-belnr.
*  ENDLOOP.

***performance fix by Rahmadi
*  SELECT vbeln gjahr fakturno
*    FROM zGDTXdt0002
*    INTO TABLE lt_02
** changed by pendi on 9/6/2003
**    WHERE vkorg =  p_bukrs
*    WHERE bukrs =  p_bukrs
*      AND vbeln IN ls_belnr
*      AND gjahr = p_gjahr.

  REFRESH lt_02. CLEAR: ld_from, ld_to.
  ld_from = 1.
  ld_to = c_max_ritems.
  DO.
    REFRESH lr_belnr.
    LOOP AT ls_belnr FROM ld_from TO ld_to.
      lr_belnr = ls_belnr.
      APPEND lr_belnr.
    ENDLOOP.
    IF lr_belnr[] IS INITIAL.
      EXIT.
    ENDIF.
    ld_from = ld_from + c_max_ritems.
    ld_to   = ld_to   + c_max_ritems.

    SELECT vbeln gjahr fakturno
      FROM zgdtxdt0002
      APPENDING CORRESPONDING FIELDS OF TABLE lt_02
      WHERE bukrs =  p_bukrs
        AND vbeln IN lr_belnr
        AND gjahr = p_gjahr.

  ENDDO.
****end of performance fix by Rahmadi

*--modify by pendi
*-- add the hkont condition to get all the acc. no
*--- where gl/account is in zGDTXdt0104 table
*--- and then read bseg again with additional key
*--- where posting key start with 0/2 to get customer/vendor info.

***performance fix by Rahmadi
*  SELECT bukrs belnr gjahr buzei shkzg bschl kunnr wrbtr dmbtr
*         sgtxt hkont gsber
*  FROM bseg
*  INTO CORRESPONDING FIELDS OF TABLE lt_bseg
**-- added by pendi on 11/6/2003
****modified by Rahmadi
**  FOR ALL ENTRIES IN t_zGDTXdt0104
*  WHERE
**        hkont = t_zGDTXdt0104-hkont
*        bukrs = p_bukrs
*    AND belnr IN ls_belnr
*    AND gjahr = p_gjahr
*    AND hkont IN r_hkont.

  REFRESH lt_bseg. CLEAR: ld_from, ld_to.
  ld_from = 1.
  ld_to = c_max_ritems.
  DO.
    REFRESH lr_belnr.
    LOOP AT ls_belnr FROM ld_from TO ld_to.
      lr_belnr = ls_belnr.
      APPEND lr_belnr.
    ENDLOOP.
    IF lr_belnr[] IS INITIAL.
      EXIT.
    ENDIF.
    ld_from = ld_from + c_max_ritems.
    ld_to   = ld_to   + c_max_ritems.

    SELECT bukrs belnr gjahr buzei shkzg bschl kunnr wrbtr dmbtr
           sgtxt hkont gsber zfbdt zterm zuonr fwbas hwbas
    FROM bseg
    APPENDING CORRESPONDING FIELDS OF TABLE lt_bseg
    WHERE
          bukrs = p_bukrs
      AND belnr IN lr_belnr
      AND gjahr = p_gjahr
      AND hkont IN r_hkont.
  ENDDO.
***end of performance fix by Rahmadi


***end of modification
* removed this cond by pendi on 9/6/2003
*    AND gsber = p_gsber.

***Added by Rahmadi
**Put User Exit for determining branch here (company specific)
  PERFORM f_select_branch TABLES lt_bseg
                          USING  p_bukrs
                                 p_brnch.

  lt_belnr1[] = lt_bseg[].
  SORT lt_belnr1 BY belnr.
  DELETE ADJACENT DUPLICATES FROM lt_belnr1 COMPARING belnr.
  CHECK NOT lt_belnr1[] IS INITIAL.
***end of addition

*-- added by pendi this selection is to get customer/Vendor information

  SELECT bukrs belnr gjahr buzei shkzg bschl
         kunnr lifnr wrbtr dmbtr sgtxt hkont gsber
         zfbdt zterm zuonr hwbas kidno
  FROM bseg
  INTO CORRESPONDING FIELDS OF TABLE lt_bseg2
  FOR ALL ENTRIES IN lt_belnr1    "added by Rahmadi
  WHERE bukrs = p_bukrs
***modified by Rahmadi
*    AND belnr IN ls_belnr
    AND belnr = lt_belnr1-belnr
***end of modification
    AND gjahr = p_gjahr
    AND ( bschl LIKE '0%' OR
          bschl LIKE '1%' OR
          bschl LIKE '2%' ).

*--end of addition

***added for Tempo
***TNT only -- get Materai line item
  IF p_bukrs = d_tnt_bukrs AND
     NOT r_hkont_mt[] IS INITIAL.
    IF lt_belnr1[] IS NOT INITIAL.
      SELECT bukrs belnr gjahr buzei shkzg bschl
             wrbtr dmbtr sgtxt hkont gsber
             zfbdt zterm zuonr hwbas
      FROM bseg
      INTO CORRESPONDING FIELDS OF TABLE lt_bseg_mt
      FOR ALL ENTRIES IN lt_belnr1    "added by Rahmadi
      WHERE bukrs = p_bukrs
        AND belnr = lt_belnr1-belnr
        AND gjahr = p_gjahr
        AND hkont IN r_hkont_mt.
      SORT lt_bseg_mt BY belnr.
    ENDIF.
  ENDIF.
***end of Tempo addition


***added for Tempo
*-Get payment terms
  lt_zterm[] = lt_bseg2[].
  SORT lt_zterm BY zterm.
  DELETE ADJACENT DUPLICATES FROM lt_zterm COMPARING zterm.
  IF lt_zterm[] IS NOT INITIAL.
    SELECT zterm ztag1
           INTO TABLE t_t052
           FROM t052
           FOR ALL ENTRIES IN lt_zterm
           WHERE zterm = lt_zterm-zterm.
    SORT t_t052 BY zterm.
  ENDIF.
***end of Tempo addition

*--modify by Pendi
*  SORT lt_bseg BY belnr gjahr hkont shkzg.
  SORT lt_bseg BY belnr gjahr shkzg.

*-- added by pendi
  SORT lt_bseg2 BY belnr gjahr.

*changed by pendi
*  IF NOT lt_bseg[] IS INITIAL.
  IF NOT lt_bseg2[] IS INITIAL.
    SELECT kunnr name1 stceg xcpdk stcd1 stras ort01 pstlz anred adrnr
      FROM kna1
      INTO TABLE lt_kna1
*      FOR ALL ENTRIES IN lt_bseg
      FOR ALL ENTRIES IN lt_bseg2
      WHERE kunnr = lt_bseg2-kunnr.
    SORT lt_kna1 BY kunnr.

*--get all vendor information, added by Pendi
    SELECT lifnr name1 stceg xcpdk stcd1 stras ort01 pstlz anred adrnr
      FROM lfa1
      INTO TABLE lt_lfa1
      FOR ALL ENTRIES IN lt_bseg2
      WHERE lifnr = lt_bseg2-lifnr.
    SORT lt_lfa1 BY lifnr.

****added by Rahmadi 02/06/2004 to get extended addresses
    APPEND LINES OF lt_kna1 TO lt_adrnr.
    APPEND LINES OF lt_lfa1 TO lt_adrnr.
    SORT lt_adrnr BY adrnr.
    DELETE ADJACENT DUPLICATES FROM lt_adrnr COMPARING adrnr.

    IF NOT lt_adrnr[] IS INITIAL.
      SELECT addrnumber title name1 str_suppl1 street str_suppl2 str_suppl3
             location city1 post_code1 city2 name_co
             INTO CORRESPONDING FIELDS OF TABLE t_adrc
             FROM adrc
             FOR ALL ENTRIES IN lt_adrnr
             WHERE addrnumber = lt_adrnr-adrnr.
      SORT t_adrc BY addrnumber.
    ENDIF.
****end of addition by Rahmadi

*end of addition
  ENDIF.


  LOOP AT lt_bkpf.
    CLEAR:
      lt_bseg,
      lt_kna1,
      lt_lfa1, "added by pendi
      lt_adrnr,
      t_data.

** Revise by Budi (08/06/2006)
    lt_bkpf-kursf = lt_bkpf-kursf * 10.
** End Revise by Budi (08/06/2006)

*   HKONT = 2140319000
    READ TABLE lt_bseg WITH KEY belnr = lt_bkpf-belnr
                                gjahr = lt_bkpf-gjahr
*commented out by Pendi on 11/06/2003
*no longer need to check GL/Account since it already
*done at the above select statement
*                                hkont = p_hkont
* didik
*                                shkzg = 'H'
                                BINARY SEARCH.
    CHECK lt_bseg-wrbtr NE 0.
    MOVE-CORRESPONDING lt_bkpf TO t_data.

    m_m :
      sy-mandt     mandt,
*      p_bukrs      vkorg,
*      p_gsber      gsber,
      p_bukrs      bukrs,
      p_brnch      brnch,

***removed for Tempo --moved to further down, from Customer line
*      p_mspjk      fakdat,
***end of Tempo changes

***modified by Rahmadi
*     '99'          spart,
*     '99'          busln,
      p_busln       busln,
***end of modification

***removed for Tempo --moved to further down, from Customer line
*      p_masatx     masatx,
***end of Tempo removal

     '1'           itqty,
     '1'           itqtylast,
     'L'           rectype,
     'S'           faktur_type,
*     'X'           exclude,
     'S'           table,
     '3'           icon.

    IF p_excld = 'X'.
      m_m 'X' exclude.
    ENDIF.

    m_m :
      lt_bkpf-belnr   belnr,
      lt_bkpf-gjahr   gjahr,
      lt_bkpf-belnr   vbeln,
***modified by Rahmadi --- Currency must be shown in Local Currency
*      lt_bkpf-waers   itcurr,
*      lt_bkpf-waers   waerk,
      'IDR'           itcurr,
      'IDR'           waerk,
***end of modification

** Revise by Budi (08/06/2006)
      lt_bkpf-waers   trcurr,
      lt_bkpf-kursf   rate_std,
      lt_bkpf-kursf   rate_tax,
** End Revise by Budi (08/06/2006)

***changed for Tempo
*      p_mspjk         fkdat.
      lt_bkpf-budat    fkdat.
***end of Tempo changes

    m_m:
      lt_bseg-buzei posnr,
** Revise by Budi (08/06/2006)
      lt_bseg-fwbas   itamt_f,
      lt_bseg-fwbas   dpp_f,
      lt_bseg-wrbtr   ppn_f,
** End Revise by Budi (08/06/2006)

***modified by Rahmadi
*      lt_bseg-wrbtr ppn,
*      lt_bseg-wrbtr ppnlast,
*      lt_bseg-wrbtr fakppn.
      lt_bseg-dmbtr ppn,
      lt_bseg-dmbtr ppnlast,
      lt_bseg-dmbtr fakppn,
      lt_bseg-hwbas hwbas.
***end of modification
    m_m: 'N'           f,
***modified by Rahmadi
*         'ARNT'        fkart,
         d_fkart_arnt   fkart,
***end of modification
         '000'         returcount.

*    CLEAR lt_bseg.
    CLEAR lt_bseg2.

*   BSCHL = 0............

*Changed by pendi on 11/6/2003
*    LOOP AT lt_bseg WHERE belnr = lt_bkpf-belnr
*                      AND gjahr = lt_bkpf-gjahr
*                      AND bschl CP '0*'.
*    ENDLOOP.

    READ TABLE lt_bseg2
         WITH KEY belnr = lt_bkpf-belnr
                  gjahr = lt_bkpf-gjahr
         BINARY SEARCH.

*    CHECK NOT lt_bseg IS INITIAL.
    CHECK NOT lt_bseg2 IS INITIAL.
*end of changes

    READ TABLE lt_02 WITH KEY vbeln = lt_bkpf-belnr.
    CHECK sy-subrc NE 0.

***added for Tempo
*---Getting Customizable Tax period & FP date
    CLEAR lt_bseg2-ztag1.
    lt_bseg2-budat = lt_bkpf-budat.
    READ TABLE t_t052 WITH KEY zterm = lt_bseg2-zterm
                      BINARY SEARCH.
    lt_bseg2-ztag1 = t_t052-ztag1.

    CALL FUNCTION 'Z_GDTXFC_EXIT_TAX_PERIOD'
      EXPORTING
*       FI_VBRK                 =
        fi_bseg                 = lt_bseg2
        fi_busln                = p_busln
*       FI_FAKDAT               =
      IMPORTING
        fe_fakdat               = ld_fakdat
        fe_masatx               = ld_masatx
        fe_gjahr                = ld_gjahr
      EXCEPTIONS
        fi_bseg_cannot_be_blank = 1
        fi_vbrk_cannot_be_blank = 2
        busline_not_defined     = 3
        OTHERS                  = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    m_m:
      ld_fakdat      fakdat,
      ld_masatx      masatx,
      ld_masatx+(4)  yeartx,
      lt_bseg2-gsber gsber.   "to display GSBER
***end of Tempo addition

** Revise by Budi (08/06/2006)
    m_m:
      lt_bseg2-zterm zterm,
      lt_bseg2-ztag1 ztag1.
** End Revise by Budi (08/06/2006)

    IF p_bukrs EQ '8160'.
      m_m:
        lt_bseg2-zuonr  item,
        lt_bseg-dmbtr itamt,
        lt_bseg2-dmbtr itamtlast,
        'IDR' waers.      "must be displayed as IDR
    ELSE.
      m_m:
        lt_bseg2-sgtxt  item,
***modified by Rahmadi
*      lt_bseg-wrbtr itamt,
*      lt_bseg-wrbtr itamtlast.
*      lt_bseg2-wrbtr itamt,
*      lt_bseg2-wrbtr itamtlast.

****** modified 19/01/2006 by dik
**      lt_bseg2-dmbtr itamt,
        lt_bseg-dmbtr itamt,
******
        lt_bseg2-dmbtr itamtlast,
***end of modification
        'IDR' waers.      "must be displayed as IDR
    ENDIF.

***added for Tempo
***for TNT only --- deduct ITAMT with materai if exist
    READ TABLE lt_bseg_mt WITH KEY belnr = lt_bkpf-belnr
                          BINARY SEARCH.
    IF sy-subrc = 0.
** Revise by Budi 05/06/2006
*      t_data-itamt = t_data-itamt - lt_bseg_mt-dmbtr.
** End Revise by Budi 05/06/2006
      t_data-itamtlast = t_data-itamt.
    ENDIF.
***end of Tempo addition

*    versi 1
*      lt_bseg-wrbtr dpp,
*      lt_bseg-wrbtr dpplast.

*    versi 2
*    t_data-dpp = t_data-itamt - t_data-itdisc - t_data-ppn.
*    t_data-dpplast =
*                 t_data-itamtlast - t_data-itdisclast - t_data-ppnlast.

*    versi 3
***modified by Rahmadi ==> DPP = ITAMT - TAX
*    t_data-dpp = t_data-ppn * p_tax.          "10.
*    t_data-dpplast = t_data-ppnlast * p_tax.  "10.
*    t_data-dpp = t_data-itamt - t_data-ppn.
*    t_data-dpplast = t_data-itamtlast - t_data-ppnlast.
*    t_data-fakdpp = t_data-dpplast.
***end of modification

****modified for Tempo  --- to cater Doc with no AR line items
*    IF t_data-ppn LE t_data-itamt.
    PERFORM f_calc_dpp USING lt_bseg-belnr
                             lt_bkpf-waers
                             lt_bkpf-budat
                             t_data-ppn
                             t_data-itamt
                             t_data-hwbas
                    CHANGING t_data-dpp
                             t_data-itamt.
    t_data-dpplast = t_data-fakdpp = t_data-dpp.
*      t_data-itamt = t_data-dpp + t_data-ppn.
    t_data-itamtlast = t_data-itamt.
*    ENDIF.
****end of Tempo modification

*    IF p_excld = 'X'.
*      t_data-itamt = t_data-dpp.
*      t_data-itamtlast = t_data-dpplast.
*    ENDIF.

*    versi 3
    IF p_excld = 'X'.
***modified by Rahmadi
*      t_data-itamt = lt_bseg-wrbtr - t_data-ppn.
*      t_data-itamtlast = lt_bseg-wrbtr - t_data-ppnlast.
*      t_data-itamt = lt_bseg2-wrbtr - t_data-ppn.
*      t_data-itamtlast = lt_bseg2-wrbtr - t_data-ppnlast.
****modified for Tempo
*      t_data-itamt = lt_bseg2-dmbtr - t_data-ppn.
*      t_data-itamtlast = lt_bseg2-dmbtr - t_data-ppnlast.
      t_data-itamt = t_data-dpp.
      t_data-itamtlast = t_data-itamt.
****end of Tempo modification
***end of modification
    ENDIF.

*changed by pendi
*    READ TABLE lt_kna1 WITH KEY kunnr = lt_bseg-kunnr
    IF lt_bseg2-bschl(1) = '0' OR
      lt_bseg2-bschl(1) = '1'. "Customer address
      READ TABLE lt_kna1 WITH KEY kunnr = lt_bseg2-kunnr
                                  BINARY SEARCH.

****changed by Rahmadi, requested by Darman 01/06/2004
*      PERFORM f_get_name_addr USING lt_kna1-kunnr
*                              CHANGING t_data-name
*                                       t_data-addrs1
*                                       t_data-addrs2
*                                       t_data-city
*                                       t_data-postal.
      READ TABLE lt_adrnr WITH KEY adrnr = lt_kna1-adrnr
                          BINARY SEARCH.
      PERFORM f_get_extended_addrs  USING lt_adrnr-adrnr
                                          lt_kna1-anred
                                          lt_bkpf-bukrs
                                          lt_bseg2-kidno
                                    CHANGING t_data-name
                                             t_data-addrs1
                                             t_data-addrs2
                                             t_data-city
                                             t_data-postal.
****end of changes

      m_m:
        lt_kna1-stcd1 wapu,
        lt_kna1-stceg npwp,

****added for Tempo ---update KUNNR & KUNRG
        lt_kna1-kunnr kunnr,
        lt_kna1-kunnr kunrg.
****end of Tempo addition

      IF t_data-name IS INITIAL.

********added by Rahmadi
        CONCATENATE lt_kna1-anred
                    lt_kna1-name1
                    INTO t_data-name
                    SEPARATED BY space.
********end of addition

        m_m:
***Tempo: no need to concatenate title into name
          lt_kna1-name1 name,
          lt_kna1-stras addrs1,
          lt_kna1-ort01 city,
          lt_kna1-pstlz postal.
      ENDIF.

      IF p_bukrs EQ '8050' OR p_bukrs EQ '8800' OR
        p_bukrs EQ '8230'.
        IF lt_kna1-xcpdk EQ 'X'.
          READ TABLE lt_bsec WITH KEY bukrs = p_bukrs
                                      belnr = lt_bseg2-belnr
                                      gjahr = lt_bseg2-gjahr.
          IF sy-subrc = 0.
            t_data-name  = lt_bsec-name1.
            t_data-npwp  = lt_bsec-bkref.
          ENDIF.
        ENDIF.
      ENDIF.

      IF lt_kna1-stcd1 CP 'W*'.
        t_data-wapu = 'W'.
      ELSE.
        t_data-wapu = 'N'.
      ENDIF.
*added by Pendi
    ELSE.
      READ TABLE lt_lfa1 WITH KEY lifnr = lt_bseg2-lifnr
                              BINARY SEARCH.

****changed by Rahmadi, requested by Darman 01/06/2004
*      PERFORM f_get_name_addr USING lt_lfa1-lifnr
*                              CHANGING t_data-name
*                                       t_data-addrs1
*                                       t_data-addrs2
*                                       t_data-city
*                                       t_data-postal.
      READ TABLE lt_adrnr WITH KEY adrnr = lt_lfa1-adrnr
                          BINARY SEARCH.
      PERFORM f_get_extended_addrs  USING lt_adrnr-adrnr
                                          lt_lfa1-anred
                                          lt_bkpf-bukrs
                                          ''
                                    CHANGING t_data-name
                                             t_data-addrs1
                                             t_data-addrs2
                                             t_data-city
                                             t_data-postal.
****end of changes

      m_m:
        lt_lfa1-stcd1 wapu,
        lt_lfa1-stceg npwp,

****added for Tempo ---update KUNNR & KUNRG
        lt_lfa1-lifnr kunnr,
        lt_lfa1-lifnr kunrg.
****end of Tempo addition

      IF t_data-name IS INITIAL.

********added by Rahmadi
        CONCATENATE lt_lfa1-anred
                    lt_lfa1-name1
                    INTO t_data-name
                    SEPARATED BY space.
********end of addition
        m_m:
***Tempo: no need to concatenate title into name
          lt_lfa1-name1 name,
          lt_lfa1-stras addrs1,
          lt_lfa1-ort01 city,
          lt_lfa1-pstlz postal.
      ENDIF.

      IF lt_lfa1-stcd1 CP 'W*'.
        t_data-wapu = 'W'.
      ELSE.
        t_data-wapu = 'N'.
      ENDIF.
*end off additions
    ENDIF.

    m_m:
      sy-uname   userid,
      sy-datum   udate,
      sy-uzeit   utime.

    IF t_data-wapu CP 'W*'.
      t_data-form = 'A3'.
    ELSE.
      t_data-form = 'A1'.
    ENDIF.

    APPEND t_data.
  ENDLOOP.

  SORT t_data BY belnr gjahr.

ENDFORM.                    " F_GET_SAP_DATA

*---------------------------------------------------------------------*
*       FORM f_get_name_addr                                          *
*---------------------------------------------------------------------*
*       Get name & address from FB03 - Extrass.
*---------------------------------------------------------------------*
FORM f_get_name_addr USING fu_kunnr
                              CHANGING fc_name
                                       fc_addrs1
                                       fc_addrs2
                                       fc_city
                                       fc_postal.
  DATA: lt_inlines LIKE tline OCCURS 0 WITH HEADER LINE,
        lt_lines   LIKE tline OCCURS 0 WITH HEADER LINE.
  DATA ld_name LIKE thead-tdname.

  MOVE fu_kunnr TO ld_name.
  CHECK NOT ld_name IS INITIAL.

  REFRESH lt_inlines.
  CALL FUNCTION 'READ_TEXT_INLINE'
    EXPORTING
      id              = '0001'
      inline_count    = '1'
      language        = sy-langu
      name            = ld_name
      object          = 'KNA1'
    TABLES
      inlines         = lt_inlines
      lines           = lt_lines
    EXCEPTIONS
      id              = 1
      language        = 2
      name            = 3
      not_found       = 4
      object          = 5
      reference_check = 6
      OTHERS          = 7.

  CHECK sy-subrc EQ 0.
  READ TABLE lt_lines INDEX 1.
  CHECK sy-subrc EQ 0.
  MOVE lt_lines-tdline TO fc_name.

  READ TABLE lt_lines INDEX 2.
  IF sy-subrc = 0.
    MOVE lt_lines-tdline TO fc_addrs1.
  ENDIF.

  READ TABLE lt_lines INDEX 3.
  IF sy-subrc = 0.
    MOVE lt_lines-tdline TO fc_addrs2.
  ENDIF.

  READ TABLE lt_lines INDEX 4.
  IF sy-subrc = 0.
    MOVE lt_lines-tdline TO fc_city.
  ENDIF.

  READ TABLE lt_lines INDEX 5.
  IF sy-subrc = 0.
    MOVE lt_lines-tdline TO fc_postal.
  ENDIF.

ENDFORM.                    "f_get_name_addr

*---------------------------------------------------------------------*
*       FORM f_check_data                                             *
*---------------------------------------------------------------------*
FORM f_check_data.
  DATA lv_faktur(20).
  DATA: BEGIN OF lt_bseg OCCURS 0.
          INCLUDE STRUCTURE zgdtxst0008.
        DATA: END OF lt_bseg.
  DATA: lt_data LIKE t_data OCCURS 0 WITH HEADER LINE.
  DATA: gt_vat  LIKE zfvatnr_dtl OCCURS 0 WITH HEADER LINE.

  DATA: lv_value        TYPE string,
        lv_pattern      TYPE string VALUE '++.++.++.+++-++++++++',
        lv_fakturno(21).

  lt_data[] = t_data[].
  DELETE lt_data WHERE fakturno NE space.
  IF lt_data[] IS NOT INITIAL.
    SELECT bukrs belnr gjahr buzei
           shkzg bschl kunnr lifnr wrbtr dmbtr sgtxt hkont
           zfbdt zterm gsber zuonr fwbas hwbas
           INTO CORRESPONDING FIELDS OF TABLE lt_bseg
           FROM bseg
           FOR ALL ENTRIES IN lt_data
           WHERE bukrs = lt_data-bukrs AND
                 belnr = lt_data-belnr AND
                 gjahr = lt_data-gjahr.
  ENDIF.

  LOOP AT t_data.
    PERFORM f_check_record CHANGING t_data.

***Comment by Rahmadi -- why multiplied by 100 ???
***modified by Rahmadi
*    t_data-ppn1 = t_data-ppn * 100.
*    t_data-dpp1 = t_data-dpp * 100.
*    t_data-itamt1 = t_data-itamt * 100.
    t_data-ppn1 = t_data-ppn.
    t_data-dpp1 = t_data-dpp.
    t_data-itamt1 = t_data-itamt.

    t_data-fakgr = d_fakgr.
***end of modification
*    t_data-itamt1 = t_data-dpp1 + t_data-ppn1.

    IF t_data-masatx(4) GT 2006.
      IF NOT t_data-fakturno IS INITIAL.
        IF t_data-fakdat IN gr_coretax.
          lv_value  = t_data-fakturno.
          CALL FUNCTION 'ZFTAX_CHECK'
            EXPORTING
              pi_value   = lv_value
              pi_pattern = lv_pattern
              pi_length  = 17
            IMPORTING
              pe_value   = lv_value.
          t_data-fakturno1 = lv_value.
        ELSE.
          IF t_data-fakdat IN gr_coretax.
            CALL FUNCTION 'ZF_FAKTUR'
              EXPORTING
                bukrs     = t_data-bukrs
                fakdat    = t_data-fakdat
                masatx    = t_data-masatx
                fakturin  = t_data-fakturno
              IMPORTING
                fakturout = t_data-fakturno1.
          ELSE.
            t_data-fakturno1 = t_data-nocoretax.
          ENDIF.
        ENDIF.
      ELSE.
        CLEAR: t_data-fakturno1.
      ENDIF.
    ELSE.
      t_data-fakturno1 = t_data-fakturno.
    ENDIF.

    READ TABLE lt_bseg WITH KEY bukrs = t_data-bukrs
                                belnr = t_data-belnr
                                gjahr = t_data-gjahr
                                bschl = '75'.
    IF sy-subrc EQ 0.
      t_data-asset = 'X'.
    ELSE.
      CLEAR: t_data-asset.
    ENDIF.

    IF t_data-bukrs EQ '8050' OR t_data-bukrs EQ '8800' OR
      t_data-bukrs EQ '8230'.
      READ TABLE lt_bseg WITH KEY bukrs = t_data-bukrs
                                  belnr = t_data-belnr
                                  gjahr = t_data-gjahr
                                  hkont = '0912120900'.
      IF sy-subrc EQ 0.
        t_data-asset  = 'X'.
      ENDIF.
    ENDIF.

    MODIFY t_data
       TRANSPORTING msgid msgv1 icon check
                    ppn1 dpp1 itamt1 fakgr
                    fakturno1 asset.
  ENDLOOP.
ENDFORM.                    "f_check_data

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
FORM f_top_of_page.
  DATA: ld_line1(80),
        ld_line2(80),
        ld_line3(80).

  DATA: ld_datum1(10),
        ld_datum2(10).

***removed for Tempo
*  CONCATENATE p_masatx+4(2)
*              '.'
*              p_masatx(4)
*              INTO ld_datum1.

*  WRITE p_mspjk TO ld_datum2 DD/MM/YYYY.
***end of Tempo removal

  CONCATENATE 'Company Code :' p_bukrs '-' t001-butxt
               INTO ld_line1
               SEPARATED BY space.

* changed by pendi on 9/6/2003
*  CONCATENATE 'Business Area(Branch) :' p_gsber '-' tgsbt-gtext
  CONCATENATE 'Branch :' p_brnch '-' d_cabtxt
               INTO ld_line2
               SEPARATED BY space.

***removed for Tempo
*  CONCATENATE 'Masa Pajak :' ld_datum1 '/' ld_datum2 INTO ld_line3
*               SEPARATED BY space.
***end of Tempo removal

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING ld_line1.
  PERFORM f_hdr_line2 USING ld_line2.
  PERFORM f_hdr_line3 USING ld_line3.
  PERFORM f_hdr_uline.

  WRITE : /2 icon_red_light AS ICON , 'Processed Data',
             icon_green_light AS ICON, 'Data to be processed',
             icon_yellow_light AS ICON, 'Data with errors'.

ENDFORM.                    "f_top_of_page

*---------------------------------------------------------------------*
*       FORM f_fieldcatg                                              *
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
  ld_fieldcat-currency      = fu_waers.
  ld_fieldcat-quantity      = fu_meins.
  ld_fieldcat-qfieldname    = fu_meins_f.
  ld_fieldcat-cfieldname    = fu_waers_f.
  ld_fieldcat-checkbox      = fu_checkbox.
  APPEND ld_fieldcat TO t_alv_fctlg.
  CLEAR ld_fieldcat.

ENDFORM.                    " F_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       Field definition for ALV
*----------------------------------------------------------------------*
FORM f_build_fieldcat USING t_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: ld_fakturno(19).

  PERFORM f_fieldcatg USING 'T_DATA':
  'BELNR' 'BSEG' 'BELNR'
         '' '' 'No. Doc' '' 'X' '' '' '' '' '' '',
  'GJAHR' 'BKPF' 'GJAHR'
         '' '5' 'Tahun' '' 'X' '' '' '' '' '' '',
***added for Tempo
  'MASATX' 'ZGDTXDT0002' 'MASATX'
         '' '10' 'Tax Period' '' 'X' '' '' '' '' '' '',
  'GSBER' 'ZGDTXDT0002' 'MASATX'
         '' '10' 'Bus. Area' '' 'X' '' '' '' '' '' '',
***end of Tempo addition
  'FAKTURNO1' space space
         '' '21' 'No.Faktur Pajak' '' '' '' '' '' '' '' '',
  'FAKDAT' space space
         '' '18' 'Tgl. FP' '' '' '' '' '' '' '' '',
  'F' space space
         '' '1' 'Flag Normal/Retur' '' '' '' '' '' '' '' '',
  'NAME' 'KNA1' 'NAME'
         '' '40' 'Nama Customer' '' '' '' '' '' '' '' '',
  'NPWP' space space
         '' '20' 'NPWP' '' '' '' '' '' '' '' '',
  'ITEM' space space
         '' '50' 'Nama Barang' '' '' '' '' '' '' '' '',
  'DPP' 'ZGDTXDT0002' 'DPP'
         '' '' 'DPP' '' '' '' '' '' 'WAERS' '' '',  "initially DPP1?
  'PPN' 'ZGDTXDT0002' 'PPN'
         '' '' 'PPN' '' '' '' '' '' 'WAERS' '' '',  "initially PPN1?
  'WAERS' 'ZGDTXDT0002' 'WAERS'
         '' '5' 'Curr.' '' '' '' '' '' '' '' '',
  'MSGV1' space space
         '' '50' 'Error Message' '' '' '' '' '' '' '' ''.

ENDFORM.                    "f_build_fieldcat

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_DATA
*&---------------------------------------------------------------------*
FORM f_write_data.

*  PERFORM f_alv_catalog USING t_alv_fctlg 'T_DATA':
*    'BELNR'  'No. Doc'            'BSEG' 'BELNR' '' ''   'X' '' '' '',
*    'GJAHR'  'Tahun'              'BKPF' 'GJAHR' '' ''   'X' '' '' '',
*    'FAKTURNO' 'No. Faktur Pajak'    space  space  '' '18' '' '' '' '',
*    'FAKDAT'   'Tgl. FP'             space  space  '' ''   '' '' '' '',
*    'F'        'Flag Normal/Retur'   space  space  '' '1'  '' '' '' '',
*    'NAME'     'Nama Customer'      'KNA1' 'NAME1' '' '40' '' '' '' '',
*    'NPWP'     'NPWP'               ''     ''      '' '20' '' '' '' '',
*    'ITEM'     'Nama Barang'        ''     ''      '' '50' '' '' '' ''.
*
*  PERFORM f_alv_catalog USING t_alv_fctlg 'T_DATA':
**    'DPP'    'Tagihan'            ''     ''      '' '15' '' '' '' '',
**    'PPN'      'PPN'              ''     ''      '' '13' '' '' '' ''.
**    'ITAMT1'     'Tagihan'        ''     ''      '' '15' '' 'R' '',
*    'DPP1'      'DPP'                ''     ''      '' '15' '' 'R'
*    'WAERS' '',
*    'PPN1'      'PPN' 'ZGDTXDT0002' 'PPN'      '' '13' '' 'R'
*    'WAERS' '',
*    'WAERS'  'Curr.'  'ZGDTXDT0002' 'WAERS'      '' '5' '' '' '' ''.
*
*  PERFORM f_alv_catalog USING t_alv_fctlg 'T_DATA':
*    'MSGV1'    'Error Message'       space  space  '' '50' '' '' '' ''.

  PERFORM f_build_fieldcat   USING   t_alv_fctlg[].
***end of modification

  PERFORM f_alv_get_catalog TABLES t_alv_fctlg USING
       'T_DATA' 'ZGDTXDT0002'.

  PERFORM f_alv_get_catalog TABLES t_alv_fctlg USING
       'T_DATA' 'ZGDTXDT0003'.

  PERFORM f_modify_ctlg USING t_alv_fctlg.


  PERFORM f_build_layout USING d_alv_layot.
  PERFORM f_alv_sort USING: space 'BELNR' 'X',
                            space 'GJAHR' 'X',
                            space 'POSNR' 'X'.

  PERFORM f_build_print      USING d_alv_print.
  PERFORM f_alv_build_event  USING slis_ev_top_of_page 'F_TOP_OF_PAGE'.


  PERFORM f_alv_build_event USING slis_ev_before_line_output
                                                'F_BEFORE_LINE_OUTPUT'.

  SET PF-STATUS 'ALV'.
  d_alv_status = 'ALV'.
  d_alv_stats = 'F_SET_PF_STATUS'.
  PERFORM f_alv_display1 TABLES t_data USING  'T_DATA' 'A'.

ENDFORM.                    " F_WRITE_DATA

*---------------------------------------------------------------------*
*       FORM f_modify_ctlg                                            *
*---------------------------------------------------------------------*
FORM f_modify_ctlg USING fu_alv_fctlg.
  DATA lt_alv_fctlg TYPE slis_fieldcat_alv.

  LOOP AT t_alv_fctlg INTO lt_alv_fctlg.

    IF lt_alv_fctlg-fieldname NE 'BELNR' AND
       lt_alv_fctlg-fieldname NE 'GJAHR' AND
***added for Tempo
       lt_alv_fctlg-fieldname NE 'MASATX' AND
       lt_alv_fctlg-fieldname NE 'GSBER' AND
***end of Tempo addition
       lt_alv_fctlg-fieldname NE 'FAKTURNO1' AND
       lt_alv_fctlg-fieldname NE 'FAKDAT' AND
       lt_alv_fctlg-fieldname NE 'F' AND
       lt_alv_fctlg-fieldname NE 'NAME' AND
       lt_alv_fctlg-fieldname NE 'NPWP' AND
       lt_alv_fctlg-fieldname NE 'ITEM' AND
       lt_alv_fctlg-fieldname NE 'ITAMT' AND  "initially ITAMT1?
       lt_alv_fctlg-fieldname NE 'DPP' AND    "initially DPP1?
       lt_alv_fctlg-fieldname NE 'PPN' AND    "initially PPN1?
***added by Rahmadi
       lt_alv_fctlg-fieldname NE 'WAERS' AND
***end of addition
       lt_alv_fctlg-fieldname NE 'MSGV1'.

      lt_alv_fctlg-no_out = 'X'.
      MODIFY t_alv_fctlg FROM lt_alv_fctlg TRANSPORTING no_out.
    ELSE.
      IF lt_alv_fctlg-col_pos NE 0.
        DELETE t_alv_fctlg INDEX sy-tabix.
        CONTINUE.
      ENDIF.
    ENDIF.

    lt_alv_fctlg-col_pos = 0.
    IF lt_alv_fctlg-fieldname = 'DPP' OR     "initially DPP1?
       lt_alv_fctlg-fieldname = 'PPN' OR     "initially PPN1?
       lt_alv_fctlg-fieldname = 'ITAMT' OR   "initially ITAMT1?
       lt_alv_fctlg-fieldname = 'ITEM'.
      lt_alv_fctlg-no_zero = 'X'.
    ENDIF.
    MODIFY t_alv_fctlg FROM lt_alv_fctlg TRANSPORTING col_pos no_zero.

    IF lt_alv_fctlg-fieldname = 'NAME' OR
       lt_alv_fctlg-fieldname = 'NPWP' OR
       lt_alv_fctlg-fieldname = 'ITEM' OR
***added for Tempo -- FAKDAT is editable to avoid FP date in holiday
       lt_alv_fctlg-fieldname = 'FAKDAT'.
***end of Tempo addition
      lt_alv_fctlg-input = 'X'.
      MODIFY t_alv_fctlg FROM lt_alv_fctlg TRANSPORTING input.
    ENDIF.

    IF lt_alv_fctlg-fieldname = 'BELNR' OR
       lt_alv_fctlg-fieldname = 'GJAHR'.
      lt_alv_fctlg-key = 'X'.
      MODIFY t_alv_fctlg FROM lt_alv_fctlg TRANSPORTING key.
    ELSE.
      lt_alv_fctlg-key = space.
      MODIFY t_alv_fctlg FROM lt_alv_fctlg TRANSPORTING key.
    ENDIF.

***marked out by Rahmadi
*    IF lt_alv_fctlg-fieldname = 'DPP1' OR
*       lt_alv_fctlg-fieldname = 'PPN1' OR
*       lt_alv_fctlg-fieldname = 'ITAMT1'.
*      lt_alv_fctlg-currency = 'IDR'.
*      lt_alv_fctlg-decimals_out = '0'.
*      MODIFY t_alv_fctlg FROM lt_alv_fctlg TRANSPORTING currency
*decimals_out.
*    ENDIF.
***end of removal

  ENDLOOP.
ENDFORM.                    "f_modify_ctlg
*---------------------------------------------------------------------*
*       FORM f_build_layout                                           *
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra             = 'X'.
  fu_layout-group_change_edit = 'X'.
  fu_layout-box_fieldname      = 'CHECK'.   " Nama field
  fu_layout-lights_fieldname   = 'ICON'.
ENDFORM.                    "f_build_layout

*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.

  fu_print-no_print_listinfos = 'X'.

ENDFORM.                    " F_BUILD_LAYOUT

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                        fu_selfield TYPE slis_selfield.

  CASE fu_ucomm.
    WHEN 'PROC'.                            "SAVE'
      PERFORM f_check_check.
      PERFORM f_save.
      fu_selfield-refresh = 'X'.

    WHEN 'HAPUS'.                           "Delete
      PERFORM f_check_check.
      PERFORM f_hapus.
      fu_selfield-refresh = 'X'.

    WHEN 'TAMBAH' OR
****added for Tempo --- to accomodate RETUR process
         'RETUR'.                           "SAP Data
****end of Tempo addition
      CLEAR: va_asset.
      PERFORM f_tambah USING fu_ucomm.
      fu_selfield-refresh = 'X'.

    WHEN '&IC1'.
      CHECK NOT fu_selfield-tabindex IS INITIAL.
      READ TABLE t_data INDEX fu_selfield-tabindex.
      SET PARAMETER ID 'BLN' FIELD t_data-belnr.
***changed for Tempo
*      SET PARAMETER ID 'GJR' FIELD t_data-fakdat(4).
      SET PARAMETER ID 'GJR' FIELD t_data-gjahr.
*      SET PARAMETER ID 'GJR' FIELD p_masatx(4).
***end of Tempo changes
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

    WHEN 'UPDATE'.
      LOOP AT t_data.
        PERFORM f_check_record CHANGING t_data.
        MODIFY t_data TRANSPORTING msgid msgv1 icon check.
      ENDLOOP.
      fu_selfield-refresh = 'X'.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    "f_user_command

*---------------------------------------------------------------------*
*       FORM f_check_check                                            *
*---------------------------------------------------------------------*
FORM f_check_check.
  DATA : lt_zfvattrn    TYPE STANDARD TABLE OF zfvattrn,
         lt_zfvatnr     TYPE STANDARD TABLE OF zfvatnr,
         lt_zfvatnr_dtl TYPE STANDARD TABLE OF zfvatnr_dtl.
  DATA : wa_zfvattrn    LIKE zfvattrn,
         wa_zfvatnr     LIKE zfvatnr,
         wa_zfvatnr_dtl LIKE zfvatnr_dtl.

  DATA : lr_datum TYPE RANGE OF datum,
         wa_datum LIKE LINE OF lr_datum.

  SELECT *
    FROM zfvattrn
    INTO CORRESPONDING FIELDS OF TABLE lt_zfvattrn
    WHERE vkorg EQ p_brnch.

  SELECT *
    FROM zfvatnr
    INTO CORRESPONDING FIELDS OF TABLE lt_zfvatnr
    WHERE vkorg EQ p_brnch.

  SELECT *
    FROM zfvatnr_dtl
    INTO CORRESPONDING FIELDS OF TABLE lt_zfvatnr_dtl
    WHERE vkorg EQ p_brnch.

  CLEAR: t_data.
  LOOP AT t_data WHERE check = 'X'.
    READ TABLE lt_zfvattrn INTO wa_zfvattrn
                           WITH KEY gform = t_data-form.
    IF sy-subrc = 0.
      READ TABLE lt_zfvatnr INTO wa_zfvatnr
                            WITH KEY vkbur = wa_zfvattrn-vatbr
                                     gjahr = t_data-fakdat(4).
      IF sy-subrc = 0.
        READ TABLE lt_zfvatnr_dtl INTO wa_zfvatnr_dtl
                                  WITH KEY vkbur = wa_zfvattrn-vatbr
                                           gjahr = t_data-fakdat(4)
                                           posnr = wa_zfvatnr-posnr.
        IF sy-subrc = 0.
          IF wa_zfvatnr_dtl-validfr IS NOT INITIAL AND
            wa_zfvatnr_dtl-validto IS NOT INITIAL.
            wa_datum-low      = wa_zfvatnr_dtl-validfr.
            wa_datum-high     = wa_zfvatnr_dtl-validto.
            wa_datum-sign     = 'I'.
            wa_datum-option   = 'BT'.
            APPEND wa_datum TO lr_datum.

            IF t_data-fakdat IN lr_datum.
            ELSE.
              t_data-icon = 2.
              t_data-msgid = '09'.
              t_data-msgv1 = 'Tanggal faktur tidak ada di ranges tanggal'.
            ENDIF.
          ELSE.
            t_data-icon = 2.
            t_data-msgid = '09'.
            t_data-msgv1 = 'Tanggal faktur tidak ada di ranges tanggal'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    t_data-masatx = t_data-fakdat(6).
    IF NOT va_asset IS INITIAL.
      t_data-asset  = va_asset.
      MODIFY t_data TRANSPORTING masatx asset icon msgid msgv1.
    ELSE.
      MODIFY t_data TRANSPORTING icon msgid msgv1.
    ENDIF.
    EXIT.
  ENDLOOP.

  IF t_data[] IS INITIAL.
    MESSAGE i000(zab) WITH 'No Data Selected'.
    EXIT.
  ENDIF.
ENDFORM.                    "f_check_check
*---------------------------------------------------------------------*
*       FORM f_tambah                                                 *
*---------------------------------------------------------------------*
FORM f_tambah USING fu_ucomm.
  DATA lt_fields LIKE sval OCCURS 0 WITH HEADER LINE.
  DATA ld_code(5).
  DATA ld_belnr LIKE bseg-belnr.
  DATA ld_gjahr LIKE bseg-gjahr.
  DATA ld_fakturno LIKE zgdtxdt0003-fakturno.
  DATA ld_fakdat LIKE zgdtxdt0003-fakdat.
  DATA ld_noret LIKE zgdtxdt0002-noretur.

  DEFINE m_move_value.
    READ TABLE lt_fields WITH KEY fieldname = &1.
    IF sy-subrc = 0.
      MOVE lt_fields-value TO &2.
    ENDIF.

  END-OF-DEFINITION.

  REFRESH lt_fields.
  CLEAR lt_fields.
  lt_fields-field_obl = 'X'. "Obligatory.
  lt_fields-tabname = 'BSEG'.
  lt_fields-fieldname = 'BELNR'.
  lt_fields-fieldtext = TEXT-006.
  APPEND lt_fields.
  CLEAR lt_fields-fieldtext.
  lt_fields-fieldname = 'GJAHR'.
  lt_fields-value = sy-datum(4).
  APPEND lt_fields.

***modified for Tempo --- separate RETURN process
  IF fu_ucomm = 'RETUR'.
    CLEAR lt_fields.
    lt_fields-field_obl = 'X'. "Obligatory.
    lt_fields-tabname = 'ZGDTXDT0003'.
    lt_fields-fieldname = 'FAKTURNO'.
    lt_fields-fieldtext = TEXT-005. "'No. Fak. Pjk Retur'.
    APPEND lt_fields.

***removed for Tempo
**  lt_fields-field_obl = 'X'. "Mesti bersatu sama FAKTURNO :((
*  lt_fields-tabname = 'ZGDTXDT0003'.
*  lt_fields-fieldname = 'FAKDAT'.
*  lt_fields-fieldtext = text-007. "'Tgl Fak. Pjk Retur'.
*  lt_fields-value = p_mspjk.
*  APPEND lt_fields.
***end of Tempo removal

***added for Tempo -- to accomodate external Nota Retur
    CLEAR lt_fields.
    lt_fields-field_obl = 'X'. "Obligatory.
    lt_fields-tabname = 'ZGDTXDT0002'.
    lt_fields-fieldname = 'NORETUR'.
    lt_fields-fieldtext = TEXT-010. "'Nota Retur'.
    APPEND lt_fields.
***end of Tempo addition
  ENDIF.
***end of Tempo modification

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      popup_title     = 'Process Faktur Pajak'
    IMPORTING
      returncode      = ld_code
    TABLES
      fields          = lt_fields
    EXCEPTIONS
      error_in_fields = 1
      OTHERS          = 2.
  CHECK sy-subrc EQ 0.
  CHECK ld_code IS INITIAL.

  m_move_value 'BELNR' ld_belnr.
  m_move_value 'GJAHR' ld_gjahr.

***modified for Tempo -- separate RETURN process
  IF fu_ucomm = 'RETUR'.
    m_move_value 'FAKTURNO' ld_fakturno.
***added for Tempo -- to accomodate external Nota Retur
    m_move_value 'NORETUR' ld_noret.
***end of Tempo addition
  ENDIF.
***end of Tempo modification

**removed for Tempo
*  m_move_value 'FAKDAT' ld_fakdat.
*
*  IF ld_fakdat(6) LT p_masatx.
*    MESSAGE i000(zab) WITH 'Tanggal Batal/Retur harus lebih besar'
*                            'atau sama dengan Masa Pajak'.
*    EXIT.
*  ENDIF.
**end of Tempo removal

  CHECK ld_belnr NE space AND ld_gjahr NE space.

  IF ld_fakturno IS INITIAL.
    READ TABLE t_data WITH KEY belnr = ld_belnr
                               gjahr = ld_gjahr.
    IF sy-subrc = 0.
      MESSAGE i000(zab) WITH 'Data sudah ada, tidak dapat diproses'.
      EXIT.
    ELSE.
      SELECT SINGLE bukrs brnch busln vbeln posnr gjahr fakturno masatx
        FROM zgdtxdt0002
        INTO CORRESPONDING FIELDS OF zgdtxdt0002
        WHERE bukrs = p_bukrs
          AND belnr = ld_belnr
          AND gjahr = ld_gjahr
          AND brnch = p_brnch.
      IF sy-subrc = 0.
        MESSAGE i000(zab) WITH 'Data sudah ada, tidak dapat diproses'.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.



  IF NOT ld_fakturno IS INITIAL.
    READ TABLE t_data WITH KEY belnr = ld_belnr
                               gjahr = ld_gjahr
***modified by Rahmadi
*                               fkart = 'ARNR'.
                               fkart = d_fkart_arnr.
***end of modification
    IF sy-subrc = 0.
      MESSAGE i000(zab) WITH 'Data sudah diretur, tidak dapat diproses'.
      EXIT.
    ELSE.
      SELECT SINGLE bukrs brnch busln vbeln posnr gjahr fakturno masatx
        FROM zgdtxdt0002
        INTO CORRESPONDING FIELDS OF zgdtxdt0002
        WHERE bukrs = p_bukrs
          AND belnr = ld_belnr
          AND gjahr = ld_gjahr
***modified by Rahmadi
*          AND fkart = 'ARNR'.
          AND fkart = d_fkart_arnr.
***end of modification
      IF sy-subrc = 0.
        MESSAGE i000(zab) WITH 'Data sudah diretur pada bulan'
                              zgdtxdt0002-masatx
                              ', tidak dapat diproses'.
        EXIT.
      ENDIF.
    ENDIF.

  ENDIF.

  PERFORM f_add_data USING ld_belnr ld_gjahr ld_fakturno ld_fakdat
***added for Tempo -- external Nota Retur
                           ld_noret.
***end of Tempo addition
ENDFORM.                    "f_tambah

*---------------------------------------------------------------------*
*       FORM f_add_data                                               *
* created by Pendi on 12/6/2003, keep the old one just in case we need*
* to refer something                                                  *
* the old one only read bseg as single record since the user          *
* already put GL/account at front                                     *
* now we can't do it any more                                         *
*---------------------------------------------------------------------*
FORM f_add_data USING fu_belnr fu_gjahr fu_fakturno fu_fakdat
***added for tempo
                      fu_noret.   "external NOTA RETUR number
***end of Tempo addition

  DATA: ld_bschl(5), ld_bschl2(5).

  DATA ld_fakdat LIKE zgdtxdt0003-fakdat.
  DATA ld_masatx LIKE zgdtxdt0003-masatx.
  DATA ld_gjahr LIKE bkpf-gjahr.

  DATA : lv_masatx    TYPE abper_rf,
         lv_answer(1).

  DATA ld_ppn_delta LIKE zgdtxdt0003-fakppn.
  DATA ld_dpp_delta LIKE zgdtxdt0003-fakdpp.
  DATA ld_returcount LIKE zgdtxdt0003-returcount.

  DATA : BEGIN OF lt_bsec OCCURS 0,
           bukrs LIKE bsec-bukrs,
           belnr LIKE bsec-belnr,
           gjahr LIKE bsec-gjahr,
           buzei LIKE bsec-buzei,
           name1 LIKE bsec-name1,
           stras LIKE bsec-stras,
           stcd1 LIKE bsec-stcd1,
           stcd2 LIKE bsec-stcd2,
           bkref LIKE bsec-bkref,
         END OF lt_bsec.

  DATA: BEGIN OF lt_bseg OCCURS 0.
***changed for Tempo
          INCLUDE STRUCTURE zgdtxst0008.
*        bukrs LIKE bseg-bukrs,
*        belnr LIKE bseg-belnr,
*        gjahr LIKE bseg-gjahr,
*        buzei LIKE bseg-buzei,
*        shkzg LIKE bseg-shkzg,
*        bschl LIKE bseg-bschl,
*        kunnr LIKE bseg-kunnr,
*        lifnr LIKE bseg-lifnr,
*        wrbtr LIKE bseg-wrbtr,
****added by Rahmadi
*        dmbtr LIKE bseg-dmbtr,
****end of addition
*        sgtxt LIKE bseg-sgtxt,
*        hkont LIKE bseg-hkont,
*        zfbdt LIKE bseg-zfbdt,
***end of Tempo changes
        DATA:   END OF lt_bseg.

  DATA: lt_bseg2 LIKE lt_bseg OCCURS 0 WITH HEADER LINE.
  DATA lt_zterm LIKE lt_bseg OCCURS 0 WITH HEADER LINE.
  DATA: lt_bseg_mt LIKE lt_bseg OCCURS 0 WITH HEADER LINE.

  BREAK bcrmd.

  CLEAR t_data.

  m_m :
    sy-mandt     mandt,
    p_bukrs      bukrs,

***removed for Tempo - bugfix
*    p_brnch      brnch,
***end of tempo removal

***removed for Tempo
*    p_mspjk      fakdat,
***end of Tempo removal

**modified by Rahmadi
*    '99'          busln,
    p_busln      busln,
**end of modification

***removed for Tempo
*    p_masatx     masatx,
***end of Tempo removal

    '1'           itqty,
    '1'           itqtylast,
    'L'           rectype,
    'S'           faktur_type,
    'S'           table,
    '3'           icon.

  IF p_excld = 'X'.
    m_m 'X' exclude.
  ENDIF.

  SELECT SINGLE bukrs belnr gjahr budat stblg waers blart kursf
    FROM bkpf
    INTO CORRESPONDING FIELDS OF bkpf
    WHERE bukrs = p_bukrs
      AND belnr = fu_belnr
      AND gjahr = fu_gjahr
      AND blart IN r_blart
      AND bstat EQ space
      AND stblg EQ space.

  IF sy-subrc NE 0.
    MESSAGE i000(zab) WITH 'Accounting document tidak ditemukan - BKPF'.
    EXIT.
  ENDIF.

*One time Customer
  SELECT bukrs
         belnr
         gjahr
         buzei
         name1
         stras
         stcd1
         stcd2
         bkref
   FROM bsec
   INTO TABLE lt_bsec
   WHERE bukrs = p_bukrs AND
         belnr = fu_belnr AND
         gjahr = fu_gjahr.

***modified by Budi(09/03/2006) -- Exchange Currency
  BREAK bcdik.
  bkpf-kursf = bkpf-kursf * 10.
***end of modification

  m_m :
    bkpf-belnr   belnr,
    bkpf-gjahr   gjahr,
    bkpf-belnr   vbeln,
***modified by Rahmadi -- Currency must be shown in Local Currency
*    bkpf-waers   itcurr,
*    bkpf-waers   waerk,
    'IDR'        itcurr,
    'IDR'        waerk,
    'IDR'        fakcurr,
***end of modification

***modified by Budi(09/03/2006) -- Exchange Currency
    bkpf-waers   trcurr,
    bkpf-kursf   rate_std,
    bkpf-kursf   rate_tax,
***end of modification

***changed for Tempo
*    p_mspjk      fkdat.
    bkpf-budat   fkdat.
***end of Tempo change

* get all the acc. docs from bseg
* check if one of them with Gl/Account
* that exist in zGDTXdt0104 table
* if bschl 1* then it is customer
* if bschl 3* then it is vendor
  SELECT bukrs belnr gjahr buzei
         shkzg bschl kunnr lifnr wrbtr dmbtr sgtxt hkont
         zfbdt zterm gsber zuonr fwbas hwbas
         INTO CORRESPONDING FIELDS OF TABLE lt_bseg
         FROM bseg
         WHERE bukrs = p_bukrs
         AND   belnr = fu_belnr
         AND   gjahr = fu_gjahr.

  IF sy-subrc NE 0.
    MESSAGE i000(zab) WITH 'Accounting document tidak ditemukan - BSEG'.
    EXIT.
  ELSE.
***modified by Rahmadi
*    SORT t_zGDTXdt0104 BY hkont.
    SORT r_hkont BY low.
***end of modification
    lt_bseg2[] = lt_bseg[].
    SORT lt_bseg2 BY hkont.
    LOOP AT lt_bseg2.
***modified by Rahmadi
*      READ TABLE t_zGDTXdt0104
*           WITH KEY hkont = lt_bseg2-hkont

      IF lt_bseg2-bschl EQ '75'.
        va_asset = 'X'.
      ENDIF.

*** Tambahan untuk Dragon Glory
      IF lt_bseg2-bukrs EQ '8050' OR lt_bseg2-bukrs EQ '8800' OR
        lt_bseg2-bukrs EQ '8230'.
        IF lt_bseg2-hkont EQ '0912120900'.
          va_asset = 'X'.
        ENDIF.
      ENDIF.

      READ TABLE r_hkont
           WITH KEY low = lt_bseg2-hkont
***end of modification
           BINARY SEARCH.
      IF sy-subrc <> 0.
        DELETE lt_bseg2.
      ENDIF.
    ENDLOOP.

    IF lt_bseg2[] IS INITIAL.
      MESSAGE i000(zab) WITH 'GL/Account tidak terdaftar di'
                             'VAT-out Non-trade Config table'
                             ' - ZGDTXDT0104'.
      EXIT.
    ENDIF.
  ENDIF.

***Added by Rahmadi for Tempo - bugfix
**Put User Exit for determining branch here (company specific)
  PERFORM f_select_branch TABLES lt_bseg2
                          USING  p_bukrs
                                 p_brnch.
***end of addition

***added for Tempo
***For TNT only
  IF p_bukrs = d_tnt_bukrs AND
     NOT r_hkont_mt[] IS INITIAL.
    lt_bseg_mt[] = lt_bseg[].
    DELETE lt_bseg_mt WHERE NOT hkont IN r_hkont_mt.
    SORT lt_bseg_mt BY belnr.
  ENDIF.
***end of Tempo addition


*-- if it is reach here means lt_bseg2 is not empty
*-- if it is more than one just read the first one for this time
  SORT lt_bseg2 BY buzei.
  READ TABLE lt_bseg2 INDEX 1.
  m_m:
***added for Tempo bugfix
    lt_bseg2-brnch brnch,
***end of Tempo addition

***modified by Budi(09/03/2006) -- Exchange Currency
    lt_bseg2-fwbas   itamt_f,
    lt_bseg2-fwbas   dpp_f,
    lt_bseg2-wrbtr   ppn_f,
***end of modification

    lt_bseg2-buzei posnr,
***added by Rahmadi
*    lt_bseg2-wrbtr ppn,
*    lt_bseg2-wrbtr ppnlast,
*    lt_bseg2-wrbtr fakppn.
    lt_bseg2-dmbtr ppn,
    lt_bseg2-dmbtr ppnlast.
****removed for Tempo --- to accomodate partial return
*    lt_bseg2-dmbtr fakppn.
****end of removal
***end of addition

  IF lt_bseg2-shkzg = 'H'.
* NORMAL
***added for Tempo -- partial return
    m_m:
      lt_bseg2-dmbtr fakppn.
***end of addition
    IF NOT fu_fakturno IS INITIAL OR
***added for Tempo -- external Nota Retur
       NOT fu_noret IS INITIAL.
***end of Tempo addition
      MESSAGE i000(zab) WITH 'Normal VAT'
                             'tidak perlu input Nomor Faktur Pajak'
***added for Tempo -- external Nota Retur
                             'dan Nota Retur'.
***end of Tempo addition
      EXIT.
    ENDIF.
    ld_bschl  = '0*'. "normal customer
    ld_bschl2 = '2*'. "normal vendor
    m_m: 'N'           f,
***modified by Rahmadi
*         'ARNT'        fkart,
         d_fkart_arnt   fkart,
***end of modification
         '000'         returcount.

  ELSEIF lt_bseg2-shkzg = 'S'.
* RETUR
    ld_bschl  = '1*'. "customer
    ld_bschl2 = '3*'. "vendor
    m_m: 'R'           f,
***modified by Rahmadi
*         'ARNR'        fkart,
         d_fkart_arnr  fkart.
***end of modification
***removed for Tempo --- enable partial return
*          bkpf-stblg   bilref,
*         '001'         returcount.
***end of Tempo removal

***changed for Tempo to cater external Nota retur
*    IF fu_fakturno IS INITIAL OR
*       fu_fakdat IS INITIAL.
    IF fu_fakturno IS INITIAL AND
       fu_noret IS INITIAL.
***end of Tempo changes
      MESSAGE i000(zab) WITH 'Masukkan data Faktur Pajak & Nota retur!'.
      EXIT.
    ENDIF.

***added for Tempo -- external Nota Retur
    DATA ld_err LIKE sy-subrc.
    m_m: fu_noret     noretur,
         bkpf-budat   dtretur.
    CLEAR: zgdtxdt0003, zgdtxdt0002, ld_err.
***end of Tempo addition

    SELECT SINGLE fakturno fakppn fakdpp fakdat returcount
      FROM zgdtxdt0003
      INTO CORRESPONDING FIELDS OF zgdtxdt0003
      WHERE fakturno = fu_fakturno.
    IF sy-subrc NE 0.
****added for Tempo --- for RETUR WITH NOREF (only until end of 2005)
      IF sy-datum < '20060101'.
        MESSAGE i000(zab) WITH 'Warning: No. FP Retur is not found!'
                               'Continue as Retur without reference'.
        PERFORM f_check_noref USING fu_fakturno
                              CHANGING ld_err.
        CASE ld_err.
          WHEN 1.
            MESSAGE i000(zab)
                    WITH 'Faktur pajak number has been used '
                         'by other billing in the same branch'.
*            EXIT.
          WHEN 2.
            MESSAGE i000(zab)
                    WITH 'Faktur pajak number cannot be within'
                         'current running number'.
*            EXIT.
          WHEN 3.
            MESSAGE i000(zab)
                    WITH 'Faktur pajak prefix error'.
*            EXIT.
        ENDCASE.

        zgdtxdt0002-vbeln = 'NOREF'.
        zgdtxdt0002-fakturno = fu_fakturno.
        t_data-bilref = 'NOREF'.
        t_data-fakturno = fu_fakturno.
****end of Tempo addition
      ELSE.
        IF p_bukrs <> '8190'.
          t_data-msgid = '10'.
          t_data-msgv1 = 'No. FP Retur not found in Tax Table'.
          MESSAGE i000(zab) WITH 'No. FP Retur not found in Tax Table'.
          EXIT.
        ELSE.
          t_data-fakturno1 = fu_fakturno.
        ENDIF.
      ENDIF.
    ELSE.
      SELECT SINGLE fakturno vbeln
        FROM zgdtxdt0002
        INTO CORRESPONDING FIELDS OF zgdtxdt0002
        WHERE fakturno = fu_fakturno.
      IF sy-subrc NE 0.
        t_data-msgid = '10'.
        t_data-msgv1 = 'No. FP Retur not found in Tax Table'.
        MESSAGE i000(zab) WITH 'No. FP Retur not found in Tax Table'.
        EXIT.
      ENDIF.
    ENDIF.

*** eFaktur
    CONCATENATE p_gjahr p_monat INTO lv_masatx.
    SELECT SINGLE fakturno fakppn fakdpp fakdat returcount
      FROM zgdtxdt0003
      INTO CORRESPONDING FIELDS OF zgdtxdt0003
      WHERE fakturno = fu_fakturno
        AND masatx   = lv_masatx.

    IF sy-subrc = 0.
      CONCATENATE 'No. FP' fu_fakturno 'sudah ada di period yang sama'
      INTO t_data-msgv1
      SEPARATED BY space.
      CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
        EXPORTING
          defaultoption  = 'N'
          diagnosetext1  = t_data-msgv1
          textline1      = ''
          titel          = 'Confirm'
          cancel_display = space
        IMPORTING
          answer         = lv_answer.

      CASE lv_answer.
        WHEN 'N'.
          EXIT.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.

***added for Tempo -- partial return
    ld_returcount = zgdtxdt0003-returcount + 1.
    ld_ppn_delta = zgdtxdt0003-fakppn - lt_bseg2-dmbtr.
    m_m:
      ld_ppn_delta        fakppn,
      zgdtxdt0002-vbeln   bilref,
      ld_returcount       returcount.
***end of addition
  ENDIF.


***added for Tempo
*-Get payment terms
  lt_zterm[] = lt_bseg[].
  SORT lt_zterm BY zterm.
  DELETE ADJACENT DUPLICATES FROM lt_zterm COMPARING zterm.
  IF lt_zterm[] IS NOT INITIAL.
    SELECT zterm ztag1
           INTO TABLE t_t052
           FROM t052
           FOR ALL ENTRIES IN lt_zterm
           WHERE zterm = lt_zterm-zterm.
    SORT t_t052 BY zterm.
  ENDIF.
***end of Tempo addition

* BSCHL(1) = 0/1 atau 2/3
  CLEAR lt_bseg.
  LOOP AT lt_bseg WHERE bschl CP ld_bschl OR
                        bschl CP ld_bschl2.
    EXIT. "just get once
  ENDLOOP.

  IF lt_bseg-belnr IS INITIAL.
    MESSAGE i000(zab) WITH 'Data tidak Sesuai - BSEG'.
    EXIT.
  ENDIF.

  BREAK bcrmd.
***added for Tempo
  lt_bseg-budat = bkpf-budat.
  READ TABLE t_t052 WITH KEY zterm = lt_bseg-zterm
                    BINARY SEARCH.
  lt_bseg-ztag1 = t_t052-ztag1.
  CALL FUNCTION 'Z_GDTXFC_EXIT_TAX_PERIOD'
    EXPORTING
*     FI_VBRK                 =
      fi_bseg                 = lt_bseg
      fi_busln                = p_busln
*     FI_FAKDAT               =
    IMPORTING
      fe_fakdat               = ld_fakdat
      fe_masatx               = ld_masatx
      fe_gjahr                = ld_gjahr
    EXCEPTIONS
      fi_bseg_cannot_be_blank = 1
      fi_vbrk_cannot_be_blank = 2
      busline_not_defined     = 3
      OTHERS                  = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

***Check Tax period status
  READ TABLE t_period WITH KEY brnch = p_brnch
                               masatx = ld_masatx
                               BINARY SEARCH.
  IF sy-subrc <> 0.
    MESSAGE i000(zab) WITH 'Tax period is closed or doesnot exist'.
    EXIT.
  ENDIF.

  m_m:
       ld_fakdat     fakdat,
       ld_masatx     masatx,
       ld_masatx+(4) yeartx,
***modified by Budi(09/03/2006) -- Payment Term
       lt_bseg-zterm zterm,
       lt_bseg-ztag1 ztag1,
***end of modification
*02/12/2005
*       ld_gjahr      gjahr,
       lt_bseg-gsber gsber.    "to display GSBER
***end of Tempo addition

  BREAK bcrmd.

  IF p_bukrs EQ '8160'.
    m_m:
      lt_bseg-zuonr item,
      lt_bseg2-dmbtr itamt,
      lt_bseg-dmbtr itamtlast,
      lt_bseg2-hwbas hwbas,
      'IDR' waers.      "must be displayed as IDR
  ELSE.
    m_m:
      lt_bseg-sgtxt item,
***modified by Rahmadi
*    lt_bseg-wrbtr itamt,
*    lt_bseg-wrbtr itamtlast.
      lt_bseg2-dmbtr itamt,
      lt_bseg-dmbtr itamtlast,
      lt_bseg2-hwbas hwbas,
      'IDR' waers.      "must be displayed as IDR
***end of modification
  ENDIF.

***added for Tempo
***for TNT only
  READ TABLE lt_bseg_mt WITH KEY belnr = lt_bseg-belnr
                        BINARY SEARCH.
  IF sy-subrc = 0.
*    t_data-itamt = t_data-itamt - lt_bseg_mt-dmbtr.
    t_data-itamtlast = t_data-itamt.
  ENDIF.
***end of Tempo addition


***modified for Tempo -- Tax should not be hardcoded
*  t_data-dpp     = t_data-ppn * 10.
*  t_data-dpplast = t_data-ppnlast * 10.
*  IF t_data-itamt LE t_data-ppn.  "to cater doc with no AR line items
  PERFORM f_calc_dpp USING lt_bseg-belnr
                           t_data-waers
                           bkpf-budat
                           t_data-ppn
                           t_data-itamt
                           t_data-hwbas
                     CHANGING t_data-dpp
                              t_data-itamt.

*    t_data-itamt = t_data-dpp + t_data-ppn.
  t_data-itamtlast = t_data-itamt.
*  ELSE.
*    t_data-dpp = t_data-itamt - t_data-ppn.
*  ENDIF.
  t_data-dpplast = t_data-fakdpp = t_data-dpp.
***end of Tempo modification

  IF p_excld = 'X'.
    t_data-itamt     = t_data-dpp.
    t_data-itamtlast = t_data-dpplast.
  ENDIF.

***not used
  t_data-dpp1 = t_data-dpp * 100.
  t_data-ppn1 = t_data-ppn * 100.
  t_data-itamt1 = t_data-dpp1 + t_data-ppn1.
***end of not used statements

***added for Tempo -- enable partial return
  ld_dpp_delta = zgdtxdt0003-fakdpp - t_data-dpp.
  m_m:
    ld_dpp_delta fakdpp.
***end of Tempo addition

  IF lt_bseg-bschl CP ld_bschl. "customer

***added for Tempo
*--nomor retur can't be used if it's already used by the same customer
    IF NOT fu_noret IS INITIAL.
      SELECT SINGLE noretur
                    INTO CORRESPONDING FIELDS OF zgdtxdt0002
                    FROM zgdtxdt0002
                    WHERE kunnr    = lt_bseg-kunnr AND
                          noretur  = fu_noret.
      IF sy-subrc = 0.
        MESSAGE i000(zab) WITH 'Nota retur'
                               fu_noret
                            'has been used by the same customer before'.
        EXIT.
      ENDIF.
    ENDIF.
***end of Tempo addition

    SELECT SINGLE kunnr name1 stceg xcpdk stcd1 stras ort01 pstlz anred adrnr
                  gform
      FROM kna1
      INTO CORRESPONDING FIELDS OF kna1
      WHERE kunnr = lt_bseg-kunnr.

    IF sy-subrc NE 0.
      MESSAGE i000(zab) WITH 'Data customer tidak ditemukan - KNA1'.
      EXIT.
    ELSE.
****added by Rahmadi 02/06/2004 to get extended addresses
      CLEAR adrc.
      SELECT SINGLE addrnumber title name1 str_suppl1 street str_suppl2
                    str_suppl3 location city1 post_code1 city2
                    INTO CORRESPONDING FIELDS OF adrc
                    FROM adrc
                    WHERE addrnumber = kna1-adrnr.
****end of addition by Rahmadi
    ENDIF.

****changed by Rahmadi, requested by Darman 02/06/2004
*    PERFORM f_get_name_addr USING kna1-kunnr
*                            CHANGING t_data-name
*                                     t_data-addrs1
*                                     t_data-addrs2
*                                     t_data-city
*                                     t_data-postal.
***Tempo: no need to concatenate title into name
*    CONCATENATE kna1-anred
*                adrc-name1 INTO t_data-name
*                           SEPARATED BY space.

    t_data-name = adrc-name1.

***end of tempo changes
    IF NOT adrc-str_suppl1 IS INITIAL.
      t_data-addrs1 = adrc-str_suppl1.
    ELSE.
      t_data-addrs1 = adrc-street.
    ENDIF.
    IF NOT adrc-str_suppl2 IS INITIAL.
      CONCATENATE adrc-str_suppl2 adrc-str_suppl3 INTO t_data-addrs2
      SEPARATED BY space.
      t_data-city = adrc-location.
    ELSE.
      t_data-addrs2 = adrc-location.
      t_data-city = adrc-city1.
    ENDIF.

    t_data-postal = adrc-post_code1.
****end of changes
    m_m:
      kna1-stcd1 wapu,
      kna1-stceg npwp,

****added for Tempo ---update KUNNR & KUNRG
      kna1-kunnr kunnr,
      kna1-kunnr kunrg,
****end of Tempo addition

      sy-uname   userid,
      sy-datum   udate,
      sy-uzeit   utime.

    IF t_data-name IS INITIAL.
********added by Rahmadi
      CONCATENATE kna1-anred
                  kna1-name1
                  INTO t_data-name
                  SEPARATED BY space.
********end of addition

      m_m:
***Tempo: no need to concatenate title into name
        kna1-name1 name,
        kna1-stras addrs1,
        kna1-ort01 city,
        kna1-pstlz postal.
    ENDIF.

    IF p_bukrs EQ '8050' OR p_bukrs EQ '8800' OR
      p_bukrs EQ '8230'.
      IF kna1-xcpdk EQ 'X'.
        READ TABLE lt_bsec WITH KEY bukrs = p_bukrs
                                    belnr = fu_belnr
                                    gjahr = fu_gjahr.
        IF sy-subrc = 0.
          t_data-name  = lt_bsec-name1.
          t_data-npwp  = lt_bsec-bkref.
        ENDIF.
      ENDIF.
    ENDIF.

    IF kna1-stcd1 CP 'W*'.
      t_data-wapu = 'W'.
    ELSE.
      t_data-wapu = 'N'.
    ENDIF.
  ELSE.
    SELECT SINGLE lifnr name1 stceg stcd1 stras ort01 pstlz anred
    FROM lfa1
    INTO CORRESPONDING FIELDS OF lfa1
    WHERE lifnr = lt_bseg-lifnr.

    IF sy-subrc NE 0.
      MESSAGE i000(zab) WITH 'Data vendor tidak ditemukan - LFA1'.
      EXIT.
    ELSE.
****added by Rahmadi 02/06/2004 to get extended addresses
      CLEAR adrc.
      SELECT SINGLE addrnumber title name1 str_suppl1 street str_suppl2
                    str_suppl3 location city1 post_code1 city2
                    INTO CORRESPONDING FIELDS OF adrc
                    FROM adrc
                    WHERE addrnumber = lfa1-adrnr.
****end of addition by Rahmadi
    ENDIF.
****changed by Rahmadi, requested by Darman 02/06/2004
*    PERFORM f_get_name_addr USING lfa1-kunnr
*                            CHANGING t_data-name
*                                     t_data-addrs1
*                                     t_data-addrs2
*                                     t_data-city
*                                     t_data-postal.

***Tempo: no need to concatenate title into name
*    CONCATENATE lfa1-anred
*                adrc-name1 INTO t_data-name
*                           SEPARATED BY space.
    t_data-name = adrc-name1.
***end of tempo changes
    IF NOT adrc-str_suppl1 IS INITIAL.
      t_data-addrs1 = adrc-str_suppl1.
    ELSE.
      t_data-addrs1 = adrc-street.
    ENDIF.
    IF NOT adrc-str_suppl2 IS INITIAL.
      CONCATENATE adrc-str_suppl2 adrc-str_suppl3 INTO t_data-addrs2
      SEPARATED BY space.
      t_data-city = adrc-location.
    ELSE.
      t_data-addrs2 = adrc-location.
      t_data-city   = adrc-city1.
    ENDIF.

    t_data-postal = adrc-post_code1.
****end of changes

    m_m:
      lfa1-stcd1 wapu,
      lfa1-stceg npwp,

****added for Tempo ---update KUNNR & KUNRG
      lfa1-lifnr kunnr,
      lfa1-lifnr kunrg,
****end of Tempo addition

      sy-uname   userid,
      sy-datum   udate,
      sy-uzeit   utime.

    IF t_data-name IS INITIAL.
********added by Rahmadi
      CONCATENATE lfa1-anred
                  lfa1-name1
                  INTO t_data-name
                  SEPARATED BY space.
********end of addition

      m_m:
***Tempo: no need to concatenate title into name
        lfa1-name1 name,
        lfa1-stras addrs1,
        lfa1-ort01 city,
        lfa1-pstlz postal.
    ENDIF.


    IF lfa1-stcd1 CP 'W*'.
      t_data-wapu = 'W'.
    ELSE.
      t_data-wapu = 'N'.
    ENDIF.
  ENDIF.

  IF t_data-wapu CP 'W*'.
    t_data-form = 'A3'.
  ELSE.
    IF p_bukrs EQ '8050' OR p_bukrs EQ '8800'.
      t_data-form = 'A1'.
    ELSE.
      IF kna1-gform EQ 'A5'.
        t_data-form = 'A5'.
      ELSE.
        t_data-form = 'A1'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF NOT fu_fakturno IS INITIAL.
    MOVE fu_fakturno TO t_data-fakturno.
  ENDIF.

***removed for Tempo
*  MOVE fu_fakdat TO t_data-fakdat.
***end of Tempo removal
  t_data-fakgr = d_fakgr.

  PERFORM f_check_record CHANGING t_data.
  APPEND t_data.

ENDFORM.                    "f_add_data

*---------------------------------------------------------------------*
*       FORM f_add_data_old                                           *
*---------------------------------------------------------------------*
FORM f_add_data_old USING fu_belnr fu_gjahr fu_fakturno fu_fakdat.
  DATA:
    bseg0 LIKE bseg,
    bseg1 LIKE bseg.
  DATA ld_bschl(5).

  m_m :
    sy-mandt     mandt,
*    p_bukrs      vkorg,
*    p_gsber      gsber,
    p_bukrs      bukrs,
    p_brnch      brnch,
    p_mspjk      fakdat,
*   '99'          spart,
***modified by Rahmadi
*   '99'          busln,
    p_busln      busln,
***end of modification
    p_masatx     masatx,
    p_masatx+(4) yeartx,
   '1'           itqty,
   '1'           itqtylast,
   'L'           rectype,
   'S'           faktur_type,
   'S'           table,
   '3'           icon.

  IF p_excld = 'X'.
    m_m 'X' exclude.
  ENDIF.


  SELECT SINGLE bukrs belnr gjahr budat stblg waers blart
    FROM bkpf
    INTO CORRESPONDING FIELDS OF bkpf
    WHERE bukrs = p_bukrs
*commented out by Pendi on 11/6/2003
*      AND blart = p_blart
      AND bstat EQ space
      AND stblg EQ space
      AND belnr = fu_belnr
      AND gjahr = fu_gjahr.

  IF sy-subrc NE 0.
*    MESSAGE i000(zab) WITH 'Data tidak Sesuai - BKPF'.
    MESSAGE i000(zab) WITH 'Accounting document tidak ditemukan - BKPF'
.
    EXIT.
*--added by Pendi on 11/6/2003
  ELSE.
***modified by Rahmadi
*    SORT t_zGDTXdt0104 BY blart.
    SORT r_blart BY low.
*    READ TABLE t_zGDTXdt0104
*         WITH KEY blart = bkpf-blart
    READ TABLE r_blart
         WITH KEY low = bkpf-blart
         BINARY SEARCH.
***end of modification
    IF sy-subrc <> 0.
      MESSAGE i000(zab) WITH 'Document type tidak terdaftar di'
                             'VAT-out Non-trade Config table'
                             ' - zGDTXdt0104'.
      EXIT.
    ENDIF.
*-- end of addition
  ENDIF.

  m_m :
    bkpf-belnr   belnr,
    bkpf-gjahr   gjahr,
    bkpf-belnr   vbeln,
***modified by Rahmadi -- Currency must be shown in Local Currency
*    bkpf-waers   itcurr,
*    bkpf-waers   waerk,
    'IDR'        itcurr,
    'IDR'        waerk,
***end of modification
    p_mspjk      fkdat.

* HKONT = 2140319000
  SELECT SINGLE bukrs belnr gjahr buzei
         shkzg bschl kunnr wrbtr dmbtr sgtxt hkont
         zfbdt zterm zuonr
         INTO CORRESPONDING FIELDS OF bseg
         FROM bseg
         WHERE bukrs = p_bukrs
         AND belnr = fu_belnr
         AND gjahr = fu_gjahr.
* removed by pendi on 9/6/2003
*    AND gsber = p_gsber
*    AND hkont = p_hkont.

  IF sy-subrc NE 0.
    MESSAGE i000(zab) WITH 'Accounting document tidak ditemukan - BSEG'.
    EXIT.
*--added by Pendi on 11/6/2003
*  ELSE.
*    sort t_zGDTXdt0104 by hkont.
*    read table t_zGDTXdt0104
*         with key hkont = bseg-hkont
*         binary search.
*
*    if sy-subrc <> 0.
*      MESSAGE i000(zab) WITH 'GL/Account tidak terdaftar di'
*                             'VAT-out Non-trade Config table'
*                             ' - zGDTXdt0104'.
*      EXIT.
*    endif.
**-- end of addition
  ENDIF.

  m_m:
    bseg-buzei posnr,
***modified by Rahmadi
*    bseg-wrbtr ppn,
*    bseg-wrbtr ppnlast,
*    bseg-wrbtr fakppn.
    bseg-dmbtr ppn,
    bseg-dmbtr ppnlast,
    bseg-dmbtr fakppn.
***end of modification
  IF bseg-shkzg = 'H'.
* NORMAL
    IF NOT fu_fakturno IS INITIAL.
      MESSAGE i000(zab) WITH 'Normal VAT'
                              'tidak perlu input Nomor Faktur'.
      EXIT.
    ENDIF.
    ld_bschl = '0%'.
    m_m: 'N'           f,
***modified by Rahmadi
*         'ARNT'        fkart,
         d_fkart_arnt  fkart,
***end of modification
         '000'         returcount.

  ELSEIF bseg-shkzg = 'S'.
* RETUR
    ld_bschl = '1%'.
    m_m: 'R'           f,
***modified by Rahmadi
*         'ARNR'        fkart,
         d_fkart_arnr  fkart,
***end of modification
          bkpf-stblg   bilref,
         '001'         returcount.

    IF fu_fakturno IS INITIAL OR fu_fakdat IS INITIAL .
      MESSAGE i000(zab) WITH 'Masukkan data Faktur Pajak dan Tanggal!'.
      EXIT.
    ENDIF.

    SELECT SINGLE fakturno fakdat
      FROM zgdtxdt0003
      INTO CORRESPONDING FIELDS OF zgdtxdt0003
      WHERE fakturno = fu_fakturno.
    IF sy-subrc NE 0.
      t_data-msgid = '10'.
      t_data-msgv1 = 'No. FP Retur not found in Tax Table'.
      MESSAGE i000(zab) WITH 'No. FP Retur not found in Tax Table'.
      EXIT.
    ELSE.
      SELECT SINGLE fakturno
        FROM zgdtxdt0002
        INTO CORRESPONDING FIELDS OF zgdtxdt0002
        WHERE fakturno = fu_fakturno.
      IF sy-subrc NE 0.
        t_data-msgid = '10'.
        t_data-msgv1 = 'No. FP Retur not found in Tax Table'.
        MESSAGE i000(zab) WITH 'No. FP Retur not found in Tax Table'.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

* BSCHL(1) = 0 atau 1
  SELECT SINGLE bukrs belnr gjahr buzei shkzg bschl kunnr wrbtr
                dmbtr sgtxt zfbdt zterm zuonr
  FROM bseg
  INTO CORRESPONDING FIELDS OF bseg0
  WHERE bukrs = p_bukrs
    AND belnr = fu_belnr
    AND gjahr = fu_gjahr
    AND bschl LIKE ld_bschl.

  IF sy-subrc NE 0.
    MESSAGE i000(zab) WITH 'Data tidak Sesuai - BSEG'
                             ld_bschl.
    EXIT.
  ENDIF.

  IF p_bukrs EQ '8160'.
    m_m:
      bseg0-zuonr item,
      bseg0-dmbtr itamt,
      bseg0-dmbtr itamtlast.
  ELSE.
    m_m:
      bseg0-sgtxt item,
***modified by Rahmadi
*    bseg0-wrbtr itamt,
*    bseg0-wrbtr itamtlast.
      bseg0-dmbtr itamt,
      bseg0-dmbtr itamtlast.
***end of modification
  ENDIF.

*   versi 1:
*    bseg0-wrbtr dpp,
*    bseg0-wrbtr dpplast.

*    versi 2:
*  t_data-dpp = t_data-itamt - t_data-itdisc - t_data-ppn.
*  t_data-dpplast =
*               t_data-itamtlast - t_data-itdisclast - t_data-ppnlast.

*    versi 3:
  t_data-dpp = t_data-ppn * 10.
  t_data-dpplast = t_data-ppnlast * 10.

  IF p_excld = 'X'.
    t_data-itamt = t_data-dpp.
    t_data-itamtlast = t_data-dpplast.
  ENDIF.

  t_data-dpp1 = t_data-dpp * 100.
  t_data-ppn1 = t_data-ppn * 100.
  t_data-itamt1 = t_data-dpp1 + t_data-ppn1.

  SELECT SINGLE kunnr name1 stceg stcd1 stras ort01 pstlz anred
    FROM kna1
    INTO CORRESPONDING FIELDS OF kna1
    WHERE kunnr = bseg0-kunnr.

  IF sy-subrc NE 0.
    MESSAGE i000(zab) WITH 'Data tidak Sesuai - KNA1'.
    EXIT.
  ENDIF.

  PERFORM f_get_name_addr USING kna1-kunnr
                          CHANGING t_data-name
                                   t_data-addrs1
                                   t_data-addrs2
                                   t_data-city
                                   t_data-postal.

  m_m:
    kna1-stcd1 wapu,
    kna1-stceg npwp,
    sy-uname   userid,
    sy-datum   udate,
    sy-uzeit   utime.

  IF t_data-name IS INITIAL.
********added by Rahmadi
    CONCATENATE kna1-anred
                kna1-name1
                INTO t_data-name
                SEPARATED BY space.
********end of addition

    m_m:
***Tempo: no need to concatenate title into name
      kna1-name1 name,
      kna1-stras addrs1,
      kna1-ort01 city,
      kna1-pstlz postal.
  ENDIF.


  IF kna1-stcd1 CP 'W*'.
    t_data-wapu = 'W'.
  ELSE.
    t_data-wapu = 'N'.
  ENDIF.

  IF t_data-wapu CP 'W*'.
    t_data-form = 'A3'.
  ELSE.
    t_data-form = 'A1'.
  ENDIF.

  IF NOT fu_fakturno IS INITIAL.
    MOVE fu_fakturno TO t_data-fakturno.
  ENDIF.
  MOVE fu_fakdat TO t_data-fakdat.

  PERFORM f_check_record CHANGING t_data.
  APPEND t_data.

ENDFORM.                    "f_add_data_old

*---------------------------------------------------------------------*
*       FORM f_check_record                                           *
*---------------------------------------------------------------------*
FORM f_check_record CHANGING fc_data LIKE t_data.
* 0 = Error
* 1 = Warning
* 9 = Success.

* 01 = Nama Customer Blank
* 02 = NPWP Blank --> not used.
* 02 = Nama Barang Blank

* 03 = NPWP Blank
* 04 = Tax period is closed or does not exist

  CLEAR fc_data-msgid.
  CLEAR fc_data-msgv1.

***Added for Tempo
  IF fc_data-msgid IS INITIAL.
    READ TABLE t_period WITH KEY brnch = p_brnch
                                 masatx = fc_data-masatx
                                 BINARY SEARCH.
    IF sy-subrc <> 0.
      fc_data-msgid = '04'.
      fc_data-msgv1 = 'Masa pajak sudah ditutup atau tidak ada'.
    ENDIF.
  ENDIF.
***end of Tempo addition

  IF fc_data-msgid IS INITIAL.
    IF fc_data-name IS INITIAL.
      fc_data-msgid = '01'.
* changed by pendi on 9/6/2003
*      fc_data-msgv1 = 'Nama Customer tidak ada'.
      fc_data-msgv1 = 'Nama Pelanggan tidak ada'.
    ENDIF.
  ENDIF.

  IF fc_data-msgid IS INITIAL.
    IF fc_data-item IS INITIAL.
      fc_data-msgid = '02'.
      fc_data-msgv1 = 'Nama Barang tidak ada'.
    ENDIF.
  ENDIF.

  DATA ld_strlen TYPE i.
  IF fc_data-msgid IS INITIAL.
****changed for Tempo
****No need to check NPWP when processing FP Sederhana
    ld_strlen = strlen( fc_data-npwp ).
* transport DEVK927362
*    IF p_sedh IS INITIAL.
*      IF fc_data-npwp IS INITIAL OR ld_strlen LT 10.
*        fc_data-msgid = '03'.
*        fc_data-msgv1 = 'NPWP tidak ada'.
*      ENDIF.
**    ELSE.
**      IF NOT fc_data-npwp IS INITIAL OR ld_strlen GT 10.
**        fc_data-msgid = '03'.
**        fc_data-msgv1 = 'Customer mempunyai NPWP'.
**      ENDIF.
*    ENDIF.
  ENDIF.
***end of Tempo changes

  IF fc_data-msgid CP '0*'.
    fc_data-check = '0'.
    fc_data-icon = '2'.
  ELSE.
    fc_data-check = space.

    IF fc_data-table = 'T'.
      fc_data-icon = '1'.
      fc_data-check = space.
    ELSEIF fc_data-table = 'S'.
      fc_data-icon = '3'.
      fc_data-check = 'X'.
    ENDIF.

  ENDIF.

ENDFORM.                    "f_check_record

*---------------------------------------------------------------------*
*       FORM F_BEFORE_LINE_OUTPUT                                     *
*---------------------------------------------------------------------*
FORM f_before_line_output USING fu_lineinfo TYPE slis_lineinfo.

  CHECK NOT fu_lineinfo-tabindex IS INITIAL.

*  break ibm_rahmadi.
*  CALL FUNCTION 'REUSE_ALV_LIST_LAYOUT_INFO_GET'
*   IMPORTING
**     ES_LAYOUT                        =
*     et_fieldcat                      = t_alv_fctlg[]
**     ET_SORT                          =
**     ET_FILTER                        =
**     ES_LIST_SCROLL                   =
**     ES_VARIANT                       =
**     E_WIDTH                          =
**     ET_MARKED_COLUMNS                =
**     ET_FILTERED_ENTRIES              =
**     ET_FILTERED_ENTRIES_HEADER       =
**     ET_FILTERED_ENTRIES_ITEM         =
**   TABLES
**     ET_OUTTAB                        =
**     ET_OUTTAB_HEADER                 =
**     ET_OUTTAB_ITEM                   =
**     ET_COLLECT00                     =
**     ET_COLLECT01                     =
**     ET_COLLECT02                     =
**     ET_COLLECT03                     =
**     ET_COLLECT04                     =
**     ET_COLLECT05                     =
**     ET_COLLECT06                     =
**     ET_COLLECT07                     =
**     ET_COLLECT08                     =
**     ET_COLLECT09                     =
*   EXCEPTIONS
*     no_infos                         = 1
*     program_error                    = 2
*     OTHERS                           = 3
*            .
*  IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.


  READ TABLE t_data INDEX fu_lineinfo-tabindex.
  CHECK sy-subrc EQ 0.
  IF NOT t_data-fakturno IS INITIAL.
    d_alv_fctlg-input = space.
    MODIFY t_alv_fctlg FROM d_alv_fctlg TRANSPORTING input
      WHERE fieldname <> ''.
*      WHERE fieldname = 'NAME'
*         OR fieldname = 'NPWP'.

    d_alv_fctlg-input = 'X'.
    MODIFY t_alv_fctlg FROM d_alv_fctlg TRANSPORTING input
      WHERE fieldname = 'ITEM1'.
  ELSE.

    d_alv_fctlg-input = 'X'.
    MODIFY t_alv_fctlg FROM d_alv_fctlg TRANSPORTING input
      WHERE fieldname = 'NAME'
         OR fieldname = 'NPWP'
         OR fieldname = 'ITEM1'.
  ENDIF.

*break ibm_rahmadi.
*  CALL FUNCTION 'REUSE_ALV_LIST_LAYOUT_INFO_SET'
*       EXPORTING
*            IS_LAYOUT   = d_alv_layot
*            it_fieldcat = t_alv_fctlg[].

ENDFORM.                    " F_BEFORE_LINE_OUTPUT

*---------------------------------------------------------------------*
*       FORM f_save                                                   *
*---------------------------------------------------------------------*
FORM f_save.
  DATA ld_subrc LIKE sy-subrc.
  DATA lt_retur LIKE t_data OCCURS 0 WITH HEADER LINE.
  DATA lt_normal LIKE t_data OCCURS 0 WITH HEADER LINE.
  DATA ld_error.
  DATA ld_delta LIKE zgdtxdt0002-itamt.

  DATA lv_faktur(20).
  DATA lv_nocoretax   TYPE zgdtxdt0011-nocoretax.

  BREAK bcrmd.
  IF d_save = 'X'.
    MESSAGE i000(zab) WITH 'Data telah disimpan, tidak dapat diulang'.
    EXIT.
  ENDIF.

  lt_retur[] = t_data[].
  lt_normal[] = t_data[].

  DELETE lt_retur WHERE f NE 'R' OR msgid NP '*'.
  DELETE lt_normal WHERE f NE 'N' OR msgid NP '*'.

  CLEAR t_data.
  LOOP AT t_data WHERE msgid NP '0*' AND check EQ 'X'.
    IF t_data-f = 'N'.
      IF t_data-fakturno IS INITIAL.
        IF t_data-msgid NE '10'.

****$$$$TO BE modified by Rahmadi
*            d_fpone = dl_fpone.
*            d_fptwo = dl_fptwo.
*
*    PERFORM f_get_faktur_no USING dl_objrange
*                                  p_brnch
*                                  p_masatx
*                         CHANGING t_data-fakturno
*                                  ld_subrc.
*    IF fc_subrc <> 0.
*      MESSAGE a000(ztx) WITH 'Please maintain number ranges'.
*    ENDIF.

          CLEAR zgdtxdt0011.
*          CONCATENATE p_gsber(1) '%' INTO zGDTXdt0011-gsber.
*          CONCATENATE p_brnch(1) '%' INTO zGDTXdt0011-brnch.
          DATA: ld_brnch LIKE zgdtxdt0011-brnch.

          IF t_data-masatx(4) GT 2006.
* changed by pendi on 9/6/2003
*            data: ld_gsber like bseg-gsber.
*            concatenate p_gsber(1) '000' into ld_gsber.
*            CONCATENATE p_brnch(1) '000' INTO ld_brnch.
            ld_brnch = p_brnch.

* -------- end of insertion

            d_fpone = dl_fpone.
            d_fptwo = dl_fptwo.

****changed for Tempo
*-----------No need to get Faktur no. if processing FP Sederhana
* transport DEVK927362
*            IF p_sedh IS INITIAL.
            PERFORM f_get_next_number USING    dl_objrange
                                              "c_objrange
*                                                 p_gsber
                                               t_data-gsber
                                               t_data-bukrs
                                               ld_brnch  "pendi
                                               t_data-masatx
                                               t_data-form
                                               t_data-asset
                                               t_data-fkdat
                                               t_data-vbeln
                                      CHANGING t_data-fakturno t_data-nocoretax
                                               ld_subrc.
            IF ld_subrc NE 0.
              MESSAGE i000(zab) WITH 'Number Range Error:'
*                                       c_objrange
                                       dl_objrange
                                       ld_brnch.      "pendi
*                                       ld_gsber.
*                                       p_gsber.
              ld_error = 'X'.
              CONTINUE.
            ELSE.
              IF t_data-nocoretax IS NOT INITIAL.
                MODIFY t_data TRANSPORTING nocoretax.
              ENDIF.
            ENDIF.
*            ELSE.
*              CLEAR t_data-fakturno.
*            ENDIF.
          ELSE.
            SELECT SINGLE fakturno masatx gsber
              FROM zgdtxdt0011
              INTO CORRESPONDING FIELDS OF zgdtxdt0011
***changed for Tempo
*            WHERE masatx = p_masatx
              WHERE
***end of Tempo changes

* changed by pendi on 9/6/2003
*              AND gsber LIKE zGDTXdt0011-gsber
*              AND brnch LIKE zGDTXdt0011-brnch
                    brnch = p_brnch
                AND objrange = dl_objrange.
            IF sy-subrc = 0.
****changed for Tempo
*-----------No need to get Faktur no. if processing FP Sederhana
* transport DEVK927362
*              IF p_sedh IS INITIAL.
              MOVE zgdtxdt0011-fakturno TO t_data-fakturno.
*              ELSE.
*                CLEAR t_data-fakturno.
*              ENDIF.
****end of tempo changes
            ELSE.
* changed by pendi on 9/6/2003
*            data: ld_gsber like bseg-gsber.
*            concatenate p_gsber(1) '000' into ld_gsber.
*            CONCATENATE p_brnch(1) '000' INTO ld_brnch.
              ld_brnch = p_brnch.

* -------- end of insertion

              d_fpone = dl_fpone.
              d_fptwo = dl_fptwo.

****changed for Tempo
*-----------No need to get Faktur no. if processing FP Sederhana
* transport DEVK927362
*              IF p_sedh IS INITIAL.
              PERFORM f_get_next_number USING    dl_objrange
                                                "c_objrange
*                                                 p_gsber
                                                 t_data-gsber
                                                 t_data-bukrs
                                                 ld_brnch  "pendi
                                                 t_data-masatx
                                                 t_data-form
                                                 t_data-asset
                                                 t_data-fkdat
                                                 t_data-vbeln
                                        CHANGING t_data-fakturno t_data-nocoretax
                                                 ld_subrc.
              IF ld_subrc NE 0.
                MESSAGE i000(zab) WITH 'Number Range Error:'
*                                       c_objrange
                                         dl_objrange
                                         ld_brnch.      "pendi
*                                       ld_gsber.
*                                       p_gsber.
                ld_error = 'X'.
                CONTINUE.
              ENDIF.
*              ELSE.
*                CLEAR t_data-fakturno.
*              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
****end of Tempo changes

        IF t_data-bukrs EQ '8050' OR p_bukrs EQ '8800'.
          PERFORM f_modify_faktuno USING t_data-vbeln t_data-gjahr
                                   CHANGING t_data-fakturno.
        ENDIF.

***$$$$$end of (TO BE) modification
        MOVE-CORRESPONDING t_data TO zgdtxdt0002.
        MOVE t_data-belnr TO zgdtxdt0002-vbeln.

        PERFORM f_modify_data USING t_data-fkdat t_data-itamt t_data-itamtlast
                              CHANGING zgdtxdt0002-itamt zgdtxdt0002-itamtlast.
        MODIFY zgdtxdt0002.

***added for Tempo for FP Sederhana -- no need to update ZGDTXDT0003
* transport DEVK927362
*        IF p_sedh IS INITIAL.
        IF t_data-msgid NE '10'.
          MOVE-CORRESPONDING t_data TO zgdtxdt0003.
***added by Rahmadi
          zgdtxdt0003-fakcurr = t_data-waerk.
***end of addition
          MODIFY zgdtxdt0003.

          "KMM3 Project
          CALL FUNCTION 'ZKMMFI_UPDATE_XREF2'
            EXPORTING
              pi_bukrs = zgdtxdt0003-bukrs
              pi_belnr = zgdtxdt0003-vbeln
              pi_gjahr = zgdtxdt0003-masatx(4)
              pi_hkont = '0315300210'
              pi_xref2 = 'PPN_OUT'.
        ENDIF.

* Revise by budi 08/03/2007
*          DELETE FROM zgdtxdt0011 WHERE fakturno = t_data-fakturno.
        DELETE zgdtxdt0011 FROM t_zgdtxdt0011.
* Revise by budi 08/03/2007

        IF t_data-masatx(4) GT 2006.
          IF NOT t_data-fakturno IS INITIAL.
            CALL FUNCTION 'ZF_FAKTUR'
              EXPORTING
                bukrs     = t_data-bukrs
                fakdat    = t_data-fakdat
                masatx    = t_data-masatx
                fakturin  = t_data-fakturno
*Begin remarks Unicode conversion - DEVK966092
*19.03.2020 - SOL_FELIX
*        CHANGING
*End remarks Unicode conversion - DEVK966092
*Begin insert Unicode conversion - DEVK966092
*19.03.2020 - SOL_FELIX
              IMPORTING
*End insert Unicode conversion - DEVK966092
                fakturout = t_data-fakturno1.
          ELSE.
            CLEAR: t_data-fakturno1.
          ENDIF.
        ELSE.
          t_data-fakturno1 = t_data-fakturno.
        ENDIF.

        IF d_coretax = 'X'.
          IF t_data-fakdat IN gr_coretax.
          ELSE.
            CLEAR t_data-fakturno1.
          ENDIF.
        ELSE.
          TRANSLATE t_data-fakturno1 USING '. '.
          TRANSLATE t_data-fakturno1 USING '- '.
          CONDENSE t_data-fakturno1 NO-GAPS.
        ENDIF.

        MODIFY t_data TRANSPORTING fakturno fakdat fakturno1.
*        ENDIF.
***end of Tempo addition
      ELSE.
        UPDATE zgdtxdt0002 SET: name = t_data-name
                                  item = t_data-item
                             WHERE fakturno = t_data-fakturno.

        UPDATE zgdtxdt0003 SET: npwp = t_data-npwp
                             WHERE fakturno = t_data-fakturno.
      ENDIF.

    ELSEIF t_data-f = 'R'.
      CLEAR ld_delta.
      READ TABLE lt_normal WITH KEY fakturno = t_data-fakturno.
      IF sy-subrc = 0.
***changed for Tempo --- possible to have partial return
        ld_delta = lt_normal-itamtlast - t_data-itamtlast.
        IF ld_delta = 0.      "clear up only when completely returned
          MOVE-CORRESPONDING lt_normal TO zgdtxdt0002.
          CLEAR:
            zgdtxdt0002-itqtylast,
            zgdtxdt0002-itamtlast,
            zgdtxdt0002-itdisclast,
            zgdtxdt0002-itothlast,
            zgdtxdt0002-dpplast,
            zgdtxdt0002-ppnlast,
            zgdtxdt0002-ppnbmlast,
            zgdtxdt0002-xppnbmlast,
            zgdtxdt0002-stnklast.
          d_fpone = space.
          d_fptwo = space.

          PERFORM f_change_to_batal USING zgdtxdt0002-fakturno.
          MODIFY zgdtxdt0002.
          DELETE FROM zgdtxdt0002 WHERE fakturno = t_data-fakturno.

*        move zGDTXdt0002-fakturno to t_data-fakturno.
*        modify t_data transporting fakturno
*               where fakturno = lt_normal-fakturno.
        ELSE.
          MOVE-CORRESPONDING lt_normal TO zgdtxdt0002.
          zgdtxdt0002-itqtylast = lt_normal-itqtylast -
                                  t_data-itqtylast.
          zgdtxdt0002-itamtlast = lt_normal-itamtlast -
                                  t_data-itamtlast.
          zgdtxdt0002-itdisclast = lt_normal-itdisclast -
                                  t_data-itdisclast.
          zgdtxdt0002-itothlast = lt_normal-itothlast -
                                  t_data-itothlast.
* dpp12
          zgdtxdt0002-dpplast = lt_normal-dpplast -
                                  t_data-dpplast.
          zgdtxdt0002-ppnlast = lt_normal-ppnlast -
                                  t_data-ppnlast.
          zgdtxdt0002-ppnbmlast = lt_normal-ppnbmlast -
                                  t_data-ppnbmlast.
          zgdtxdt0002-xppnbmlast = lt_normal-xppnbmlast -
                                  t_data-xppnbmlast.
          zgdtxdt0002-stnklast = lt_normal-stnklast -
                                  t_data-stnklast.
          MODIFY zgdtxdt0002.
        ENDIF.
      ELSE.
******for NOREF
        IF sy-datum < '20060101'.
          MOVE-CORRESPONDING t_data TO zgdtxdt0002.
          zgdtxdt0002-bilref = 'NOREF'.
          MODIFY zgdtxdt0002.
        ENDIF.
***end of Tempo changes
      ENDIF.

      MOVE-CORRESPONDING t_data TO zgdtxdt0002.

***changed for Tempo
*      MOVE p_masatx TO t_data-masatx.
      t_data-masatx = t_data-fakdat(6).
***end of Tempo changes

      IF lt_normal IS INITIAL.
*       Ini berarti beda bulan
        IF zgdtxdt0002-noretur IS INITIAL.
          d_fpone = space.
          d_fptwo = space.

****changed for Tempo
*---------No need to get FP no if processing FP Sederhana
* transport DEVK927362
*          IF p_sedh IS INITIAL.
*-----------Get NR number from credit note acc doc number
*-----------if not printing NR for VAT-out
          READ TABLE t_tx00101 WITH KEY brnch = p_brnch.
          IF t_tx00101-prtnrvo IS INITIAL.
*              zgdtxdt0002-noretur = zgdtxdt0002-belnr.
            zgdtxdt0002-dtretur = zgdtxdt0002-fkdat.
          ELSE.
            PERFORM f_get_next_number USING    c_objraret
                                               space
                                               space
                                               space
                                               t_data-masatx
                                               space
                                               space
                                               t_data-fkdat
                                               t_data-vbeln
                                      CHANGING zgdtxdt0002-noretur lv_nocoretax
                                               ld_subrc.
            IF ld_subrc NE 0.
              MESSAGE i000(zab) WITH 'Number Range Error:'
                                       c_objraret.
              ld_error ='X'.
            ELSE.
              MOVE p_mspjk TO zgdtxdt0002-dtretur.
            ENDIF.
          ENDIF.
*          ELSE.
*            CLEAR zgdtxdt0002-noretur.
*          ENDIF.
        ENDIF.
      ELSE.

****changed for Tempo -- BATAL only if completely returned
        IF ld_delta = 0.
          PERFORM f_change_to_batal USING zgdtxdt0002-fakturno.
        ENDIF.
****end of Tempo changes
*        move zGDTXdt0002-fakturno to t_data-fakturno.
*        modify t_data transporting fakturno.
      ENDIF.
      MODIFY zgdtxdt0002.

      CLEAR lt_normal.
***changed for Tempo
*-----No need to delete from ZGDTXDT0003 for FP Sederhana
* transport DEVK927362
*      IF p_sedh IS INITIAL.
      READ TABLE lt_normal WITH KEY fakturno = t_data-fakturno.
      IF sy-subrc = 0.
**       sama period dgn normal-nya, berarti hanya modifikasi yg normal.
*        lt_normal-fakppn    = 0.
*        lt_normal-fakxppnbm = 0.
*        lt_normal-fakppnbm  = 0.
*        MOVE-CORRESPONDING lt_normal TO zGDTXdt0003.
*        MODIFY zGDTXdt0003.
* changed by pendi on 9/6/2003
*        DELETE FROM zGDTXdt0003 WHERE vkorg = p_bukrs
*                                    AND gsber = p_gsber
***changed for Tempo --- delete only when completely returned
        IF ld_delta = 0.
          DELETE FROM zgdtxdt0003 WHERE bukrs = p_bukrs
                                    AND brnch = p_brnch
***removed for Tempo
*                                    AND masatx = p_masatx
***end of Tempo removal
                                     AND fakturno = t_data-fakturno.
          IF sy-subrc = 0.
            CLEAR zgdtxdt0011.
            MOVE:
              p_brnch          TO zgdtxdt0011-brnch,
              t_data-fakturno  TO zgdtxdt0011-fakturno,
              t_data-masatx    TO zgdtxdt0011-masatx,
              c_objrange       TO zgdtxdt0011-objrange,
              sy-uname         TO zgdtxdt0011-uname,
              sy-uzeit         TO zgdtxdt0011-utime,
              sy-datum         TO zgdtxdt0011-udate.
            PERFORM f_convert_ba USING p_brnch
                                  CHANGING zgdtxdt0011-brnch.
            INSERT zgdtxdt0011.
          ENDIF.
        ELSE.
****modified for Tempo -- no need to update ZGDTXDT0003 for NOREF
          IF t_data-bilref <> 'NOREF'.
            MOVE-CORRESPONDING t_data TO zgdtxdt0003.
*              IF t_data-f NE 'R'.
            MODIFY zgdtxdt0003.
*              ENDIF.

            "KMM3 Project
            CALL FUNCTION 'ZKMMFI_UPDATE_XREF2'
              EXPORTING
                pi_bukrs = zgdtxdt0003-bukrs
                pi_belnr = zgdtxdt0003-vbeln
                pi_gjahr = zgdtxdt0003-masatx(4)
                pi_hkont = '0315300210'
                pi_xref2 = 'PPN_OUT'.
          ENDIF.
****end of Tempo modification
        ENDIF.
***end of Tempo changes
      ELSE.
*       berarti beda period, jadi bikin baru.
****modified for Tempo -- no need to update ZGDTXDT0003 for NOREF
        IF t_data-bilref <> 'NOREF'.
          MOVE-CORRESPONDING t_data TO zgdtxdt0003.
*            IF t_data-f NE 'R'.
          MODIFY zgdtxdt0003.
*            ENDIF.

          "KMM3 Project
          CALL FUNCTION 'ZKMMFI_UPDATE_XREF2'
            EXPORTING
              pi_bukrs = zgdtxdt0003-bukrs
              pi_belnr = zgdtxdt0003-vbeln
              pi_gjahr = zgdtxdt0003-masatx(4)
              pi_hkont = '0315300210'
              pi_xref2 = 'PPN_OUT'.
        ENDIF.
****end of Tempo modification
      ENDIF.
*      ENDIF.
***end of Tempo changes

    ENDIF.

***added in Tempo --- change icon to RED when saved
    IF t_data-icon = '3'.
      t_data-icon = '1'.
      IF dl_coretax = 'X'.
        IF zgdtxdt0003-nocoretax IS NOT INITIAL.
          t_data-fakturno1 = zgdtxdt0003-nocoretax.
        ENDIF.
      ENDIF.
      MODIFY t_data TRANSPORTING icon fakturno1.
    ENDIF.
***end of tempo addition

  ENDLOOP.

  IF ld_error IS INITIAL.
    IF NOT t_data IS INITIAL.
      MESSAGE i000(zab) WITH 'Data telah disimpan'.
      d_save = 'X'.
    ENDIF.
  ELSE.
    CLEAR ld_error.
  ENDIF.

ENDFORM.                    "f_save

*---------------------------------------------------------------------*
*       FORM f_change_to_batal                                        *
*---------------------------------------------------------------------*
FORM f_change_to_batal USING fu_noretur.
* semula XXXXX-XXX-nnnnnnn menjadi BATAL-XXX-nnnnnnn
  CHECK NOT fu_noretur IS INITIAL.
  CHECK fu_noretur NP 'BATAL*'.
  CONCATENATE 'BATAL' fu_noretur+5 INTO fu_noretur.

ENDFORM.                    "f_change_to_batal

*---------------------------------------------------------------------*
*       FORM f_convert_ba                                             *
*---------------------------------------------------------------------*
*FORM f_convert_ba USING fu_gsber
*                     CHANGING fc_gsber.
FORM f_convert_ba USING fu_brnch
                     CHANGING fc_brnch.

  CONCATENATE fu_brnch(1) '000' INTO fc_brnch.

ENDFORM.                    "f_convert_ba
*---------------------------------------------------------------------*
*       FORM f_hapus                                                  *
*---------------------------------------------------------------------*
FORM f_hapus.
  DATA : lv_subrc   TYPE sy-subrc.

  READ TABLE t_data WITH KEY check = 'X'.
  CHECK sy-subrc = 0.

  PERFORM f_popup USING 'Delete Confirmation'
                        'Continue to delete'
                         d_answer.
  CHECK d_answer = 'X'.

  LOOP AT t_data WHERE check = 'X'.
    IF t_data-files IS INITIAL.
* changed by pendi on 9/6/2003
*   SELECT SINGLE gsber fakturno masatx
***added for Tempo -- for Sederhana & NOREF deletion
* transport DEVK927362
*    IF NOT p_sedh IS INITIAL OR
*       t_data-fakturno IS INITIAL OR
*       t_data-bilref = 'NOREF'.
*      DELETE FROM zgdtxdt0002
*        WHERE bukrs = t_data-bukrs
*          AND brnch = t_data-brnch
*          AND busln = t_data-busln
*          AND vbeln = t_data-vbeln
*          AND posnr = t_data-posnr
*          AND gjahr = t_data-gjahr
*          AND fakturno = t_data-fakturno.
*      DELETE t_data.
*    ELSE.
***end of Tempo addition

      CLEAR lv_subrc.
      IF p_bukrs = '8190'.
        IF t_data-f = 'R'.
          lv_subrc = 4.
        ENDIF.
      ENDIF.

      IF lv_subrc = 0.
        SELECT SINGLE brnch fakturno masatx
           FROM zgdtxdt0011
           INTO CORRESPONDING FIELDS OF zgdtxdt0011
*      WHERE gsber = p_gsber
           WHERE brnch = p_brnch
             AND fakturno = t_data-fakturno.
***removed for Tempo
*         AND masatx = p_masatx.
***end of Tempo removal
        CHECK sy-subrc NE 0.

        CLEAR zgdtxdt0011.
* changed by pendi on 9/6/2003
*    MOVE: p_gsber TO zGDTXdt0011-gsber,
        MOVE: p_brnch TO zgdtxdt0011-brnch,
              t_data-fakturno TO zgdtxdt0011-fakturno,
              t_data-masatx TO zgdtxdt0011-masatx,
              dl_objrange TO zgdtxdt0011-objrange,
              sy-uname TO zgdtxdt0011-uname,
              sy-datum TO zgdtxdt0011-udate,
              sy-uzeit TO zgdtxdt0011-utime.
        INSERT zgdtxdt0011.
      ENDIF.

      IF sy-subrc = 0.
        DELETE FROM zgdtxdt0003
* changed by pendi on 9/6/2003
*        WHERE vkorg = t_data-vkorg
*          AND gsber = t_data-gsber
*          AND spart = t_data-spart
          WHERE bukrs = t_data-bukrs
            AND brnch = t_data-brnch
            AND busln = t_data-busln
            AND fakturno = t_data-fakturno
            AND masatx = t_data-masatx.

        DELETE FROM zgdtxdt0002
* changed by pendi on 9/6/2003
*        WHERE vkorg = t_data-vkorg
*          AND gsber = t_data-gsber
*          AND spart = t_data-spart
          WHERE bukrs = t_data-bukrs
            AND brnch = t_data-brnch
            AND busln = t_data-busln
            AND vbeln = t_data-vbeln
            AND posnr = t_data-posnr
            AND gjahr = t_data-gjahr
            AND fakturno = t_data-fakturno.
        DELETE t_data.
      ENDIF.
*    ENDIF.
    ELSE.
      MESSAGE i000(zab)
              WITH 'Data sudah diproses eFaktur' t_data-files.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "f_hapus

*---------------------------------------------------------------------*
*       FORM f_popup                                                  *
*---------------------------------------------------------------------*
FORM f_popup USING fu_title fu_line1 fu_answer.
  DATA ld_answer.
  CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
    EXPORTING
      defaultoption = 'Y'
      textline1     = 'Continue To Delete'
      titel         = 'Delete Table ZGDTXDT00012'
    IMPORTING
      answer        = ld_answer.
  IF ld_answer = 'J'.
    d_answer = 'X'.
  ELSE.
    CLEAR d_answer.
  ENDIF.

ENDFORM.                    "f_popup


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
  REFRESH: t_data, t_zgdtxdt0104, r_blart, r_hkont.

ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Form  f_select_branch
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_select_branch TABLES ft_bseg1 STRUCTURE zgdtxst0008
                     USING  fu_bukrs
                            fu_brnch.

  LOOP AT ft_bseg1.
***Put User exit logic for determining branch in
***following function module
    CALL FUNCTION 'Z_GDTXFC_EXIT_ACCT_BRNCH_DETM'
      EXPORTING
        fi_bukrs                 = fu_bukrs
        fi_brnch                 = fu_brnch
        fi_bseg                  = ft_bseg1
      IMPORTING
        fe_bseg                  = ft_bseg1
      TABLES
        ft_tx00101               = t_tx00101
      EXCEPTIONS
        branch_is_not_maintained = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0.
      MESSAGE e000(zab) WITH 'Branch is not maintained'.
    ENDIF.
    MODIFY ft_bseg1.
  ENDLOOP.

* Based on selection parameter delete those which are not
* relevant to be processed.
  DELETE ft_bseg1 WHERE brnch <> fu_brnch OR
                        bukrs <> fu_bukrs.

ENDFORM.                    " f_select_branch
*&---------------------------------------------------------------------*
*&      Form  f_get_extended_addrs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_ADRNR  text
*      <--FC_NAME  text
*      <--FC_ADDRS1  text
*      <--FC_ADDRS2  text
*      <--FC_CITY  text
*      <--FC_POSTAL  text
*----------------------------------------------------------------------*
FORM f_get_extended_addrs USING    fu_adrnr
                                   fu_anred
                                   fu_bukrs
                                   fu_kidno
                          CHANGING fc_name
                                   fc_addrs1
                                   fc_addrs2
                                   fc_city
                                   fc_postal.

  DATA : ls_0025  TYPE zgdtxdt0025.

  READ TABLE t_adrc WITH KEY addrnumber = fu_adrnr
                    BINARY SEARCH.
  IF sy-subrc = 0.

* Revisi by Budi 31/08/2015 req. by SJT
    IF fu_bukrs = '8010' OR fu_bukrs = '8030' OR fu_bukrs = '8050' OR
       fu_bukrs = '8800' OR fu_bukrs = '8090' OR fu_bukrs = '8160' OR
       fu_bukrs = '8230' OR fu_bukrs = '8360' .
      fc_name = t_adrc-name_co.
      fc_addrs1 = t_adrc-str_suppl1.
      CONCATENATE t_adrc-str_suppl2 t_adrc-str_suppl3 INTO fc_addrs2
        SEPARATED BY space.
      fc_city = t_adrc-location.
      fc_postal = t_adrc-post_code1.
    ELSE.
* End revisi by Budi 31/08/2015 req. by SJT


***modified by Rahmadi  --- put title in name
***Tempo: no need to concatenate title into name
      fc_name = t_adrc-name1.
*    CONCATENATE fu_anred
*                t_adrc-name1 INTO fc_name
*                             SEPARATED BY space.
***end of modification
      IF NOT t_adrc-str_suppl1 IS INITIAL.
        fc_addrs1 = t_adrc-str_suppl1.
      ELSE.
        fc_addrs1 = t_adrc-street.
      ENDIF.
      IF NOT t_adrc-str_suppl2 IS INITIAL.
        fc_addrs2 = t_adrc-str_suppl2.
      ELSE.
        fc_addrs2 = t_adrc-location.
      ENDIF.
      IF fu_bukrs = '8140'.
        fc_city = t_adrc-str_suppl3.
      ELSE.
        fc_city = t_adrc-city1.
      ENDIF.
      fc_postal = t_adrc-post_code1.
    ENDIF.
  ELSE.
    CLEAR: fc_name, fc_addrs1, fc_addrs2, fc_city, fc_postal.
  ENDIF.

  IF fu_bukrs = '8160'.
    IF fu_kidno IS NOT INITIAL.
      SELECT SINGLE *
        FROM zgdtxdt0025
        INTO CORRESPONDING FIELDS OF ls_0025
        WHERE kidno = fu_kidno.

      IF sy-subrc = 0.
        fc_name    = ls_0025-name_co.
        fc_addrs1  = ls_0025-str_suppl1.
        CONCATENATE ls_0025-str_suppl2 ls_0025-str_suppl3 INTO fc_addrs2
          SEPARATED BY space.
        fc_city = ls_0025-location.
        CLEAR fc_postal.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_get_extended_addrs

*&---------------------------------------------------------------------*
*&      Form  f_calc_dpp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_DMBTR  text
*      <--FC_ITAMT  text
*----------------------------------------------------------------------*
FORM f_calc_dpp USING    fu_belnr
                         fu_waers
                         fu_budat
                         fu_ppn
                         fu_itamt
                         fu_hwbas
                CHANGING fc_dpp
                         fc_itamt.

  DATA ld_knumh LIKE konp-knumh.
  DATA ld_kbetr LIKE konp-kbetr.
  DATA ld_tax LIKE konp-kbetr.
  DATA ld_dmbtr LIKE bseg-dmbtr.

  READ TABLE t_tx00101 WITH KEY brnch = p_brnch.

*-Get INDONESIAN OUTPUT TAX
  IF fu_waers <> 'IDR'.  "bugfix by Rahmadi (Tempo)
    SELECT SINGLE knumh INTO ld_knumh
                        FROM a003
                        WHERE kappl = 'TX' AND
                              kschl = 'MWAS' AND
                              aland = 'ID' AND
                              mwskz = t_tx00101-votxcode_f.
  ELSE.
    SELECT SINGLE knumh INTO ld_knumh
                        FROM a003
                        WHERE kappl = 'TX' AND
                              kschl = 'MWAS' AND
                              aland = 'ID' AND
                              mwskz = t_tx00101-votxcode.
  ENDIF.

  IF sy-subrc = 0.
    SELECT SINGLE kbetr INTO ld_kbetr
                        FROM konp
                        WHERE knumh = ld_knumh.
    ld_tax = ld_kbetr / 10.

****Changed for Tempo --- getting DPP from ITAMT instead of PPN
****if there are AR line items
    IF fu_itamt = 0.
      fc_dpp = fu_ppn * ld_tax.
      fc_itamt = fc_dpp + fu_ppn.
    ELSE.
*      fc_dpp = fu_itamt / ( 1 + ( ld_tax / 100 ) ).
      IF fu_hwbas EQ 0.
        IF p_brnch = '8360' OR ( p_brnch = '8160' AND fu_belnr(3) NE '041' ).
          SELECT SINGLE dmbtr
            FROM bseg
            INTO ld_dmbtr
            WHERE bukrs = p_brnch
              AND belnr = fu_belnr
              AND gjahr = p_gjahr
              AND koart = 'D'.
          IF sy-subrc = 0.
            fc_dpp = ld_dmbtr - fu_ppn.
          ENDIF.
        ELSE.
          fc_dpp = fu_itamt / ( ld_tax / 100 ).
        ENDIF.
      ELSE.
        fc_dpp   = fu_hwbas.
      ENDIF.
      fc_itamt = fu_itamt.
    ENDIF.
****end of Tempo changes
  ELSE.
    MESSAGE i000(zab) WITH 'Document' fu_belnr
                           'is not tax relevant'.
  ENDIF.

  IF fu_budat > gs_dpp-datab.
    IF fc_dpp IS NOT INITIAL.
      fc_dpp = fc_dpp * 11 / 12.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_calc_dpp

*&---------------------------------------------------------------------*
*&      Form  f_check_noref
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_noref USING    fu_fakno
                   CHANGING fc_subrc.

  DATA ld_fakturno LIKE zgdtxdt0003-fakturno.

  BREAK bcrmd.
  fc_subrc = 0.
  SELECT SINGLE fakturno INTO ld_fakturno
                         FROM zgdtxdt0003
                         WHERE brnch = p_brnch AND
                               fakturno = fu_fakno.
  IF sy-subrc = 0.
    fc_subrc = 1. "fakno has been used
  ELSE.
*--Check formatting
*---FPONE
    IF fu_fakno+(5) = dl_fpone.
*-----FPTWO
      IF fu_fakno+6(3) = dl_fptwo.
        IF fu_fakno+10(7) CN '1234567890'.
          fc_subrc = 3.
        ELSE.
*---------NUMBER
          SELECT SINGLE * FROM nriv
                         WHERE object = dl_objrange AND
                               subobject = p_brnch AND
                               nrlevel <> 0.
          IF fu_fakno+10(7) GE nriv-fromnumber AND
             fu_fakno+10(7) LE nriv-tonumber.
            fc_subrc = 2. "fakno within current running range
          ENDIF.
        ENDIF.
      ELSE.
        fc_subrc = 3.  "prefix error
      ENDIF.
    ELSE.
      fc_subrc = 3.    "prefix error
    ENDIF.
  ENDIF.

ENDFORM.                    " f_check_noref

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DATA
*&---------------------------------------------------------------------*
FORM f_modify_data  USING    fu_fkdat fu_itamt fu_itamtlast
                    CHANGING fc_itamt fc_itamtlast.

  DATA : lv_value   TYPE p DECIMALS 5.

  IF fu_fkdat > gs_dpp-datab.
    lv_value      = fu_itamt * 12 / 11.
    fc_itamt      = lv_value.
    lv_value      = fu_itamtlast * 12 / 11.
    fc_itamtlast  = lv_value.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CORETAX_VALIDATE
*&---------------------------------------------------------------------*
FORM f_coretax_validate .
  DATA : ls_project TYPE zproject,
         ls_coretax LIKE LINE OF gr_coretax.

  CLEAR ls_project.
  SELECT SINGLE *
      FROM zproject
      INTO CORRESPONDING FIELDS OF ls_project
      WHERE name = 'CORETAX'.
  ls_coretax-low = ls_project-datab.

  CLEAR ls_project.
  SELECT SINGLE *
      FROM zproject
      INTO CORRESPONDING FIELDS OF ls_project
      WHERE name = 'ZGDCORETAX'.
  ls_coretax-high   = ls_project-datab.
  ls_coretax-sign   = 'I'.
  ls_coretax-option = 'BT'.
  APPEND ls_coretax TO gr_coretax.
ENDFORM.
