*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNE0006F01                                           *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_SELECT_PERIOD
*&---------------------------------------------------------------------*
FORM f_select_period.
  DATA: BEGIN OF lt_zgdtxdt0004 OCCURS 0,
          bukrs    LIKE zgdtxdt0004-bukrs,
          brnch    LIKE zgdtxdt0004-brnch,
          masatx   LIKE zgdtxdt0004-masatx,
          closedat LIKE zgdtxdt0004-closedat,
        END OF lt_zgdtxdt0004,

        ld_closedat LIKE zgdtxdt0004-closedat,
        ld_brnch    LIKE zgdtxdt0004-brnch.

  CLEAR: ld_closedat, p_masatx.
  SELECT SINGLE masatx FROM zgdtxdt0004
                       INTO p_masatx
                       WHERE bukrs    = p_bukrs AND
                             brnch    = p_brnch AND
                             closedat = ld_closedat.
  IF sy-subrc <> 0.
*     message e000(ztx) with 'No open period available for branch'.
  ENDIF.

ENDFORM.                    " F_SELECT_PERIOD


*&---------------------------------------------------------------------*
*&      Form  F_INITIALIZATION
*&---------------------------------------------------------------------*
FORM f_initialization.

ENDFORM.                    " F_INITIALIZATION

*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data.
  d_repid = sy-repid.

*$*$ don't change below
  CLEAR: d_error,sy-subrc.
  REFRESH : t_itab.

  SELECT SINGLE *
    FROM zproject
    INTO CORRESPONDING FIELDS OF gs_coretax
    WHERE name = 'CORETAX'.
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data.
  DATA: t_zgdtxdt0015 LIKE zgdtxdt0015 OCCURS 0 WITH HEADER LINE.
  DATA: t_zgdtxdt0102 LIKE zgdtxdt0102 OCCURS 0 WITH HEADER LINE.

  DATA : ld_busln(20) TYPE c,
         ld_jumlah    TYPE i,
         ld_low(6)    TYPE c,
         ld_high(6)   TYPE c,
         ld_closedat  LIKE zgdtxdt0004-closedat,
         lv_length    TYPE i.

  d_error = 0.

*Cek for masa pajak
  IF p_masatx EQ '000000'.
    d_error = 1.
    CONCATENATE 'Please enter Tax Period for'
                p_bukrs '/' p_brnch
                INTO d_posting SEPARATED BY space.
    EXIT.
  ENDIF.

  d_error = 1.
  CLEAR ld_closedat.
  SELECT SINGLE closedat FROM zgdtxdt0004
                         INTO ld_closedat
                         WHERE bukrs    = p_bukrs AND
                               brnch    = p_brnch AND
                               masatx   = p_masatx.
  IF sy-subrc = 0.
    IF NOT ld_closedat IS INITIAL.
      CONCATENATE 'Tax Period has been closed for' p_bukrs '/'
                   p_brnch
                   INTO d_posting SEPARATED BY space.
      EXIT.
    ENDIF.
  ELSE.
    CONCATENATE 'Tax period has not been created for' p_bukrs '/'
                p_brnch
                INTO d_posting SEPARATED BY space.
    EXIT.
  ENDIF.

  d_error = 0.

**Lock or Unlock for table ZGDTXdt0012
*  PERFORM f_lock_table USING p_bukrs
*                             p_brnch
*                       CHANGING d_error
*                                d_posting.
*
*  IF d_error = 3.
*    EXIT.
*  ENDIF.

*Find business unit & Range fro G/L Account
  REFRESH r_busln.
  SELECT * FROM zgdtxdt0015
  INTO TABLE t_zgdtxdt0015
   WHERE
***added by Rahmadi
         brnch = p_brnch AND
***end of addition
         busln IN s_busln.

  SELECT * FROM zgdtxdt0102
  INTO TABLE t_zgdtxdt0102
   WHERE busln IN s_busln.

  d_error = 2.
  CHECK NOT t_zgdtxdt0015[] IS INITIAL.
  d_error = 0.

  CLEAR : d_bisnisunit, ld_jumlah.
  LOOP AT t_zgdtxdt0015.
    CLEAR ld_busln.
    r_busln-low  = t_zgdtxdt0015-hkontfr.
    r_busln-high = t_zgdtxdt0015-hkontto.
    r_busln-sign = 'I'.
    r_busln-option = 'BT'.

*--- Added and commented by Rama
    READ TABLE t_zgdtxdt0102 WITH KEY busln = t_zgdtxdt0015-busln.
    ld_busln = t_zgdtxdt0102-busds.
    ADD 1 TO ld_jumlah.

*    CASE t_ZGDTXdt0015-busln.
*      WHEN '01'.
*        ld_busln = 'Finished Unit'.
*        ADD 1 TO ld_jumlah.
*      WHEN '02'.
*        ld_busln = 'Spare Parts'.
*        ADD 1 TO ld_jumlah.
*      WHEN '03'.
*        ld_busln = 'Service'.
*        ADD 1 TO ld_jumlah.
*      WHEN '99'.
*        ld_busln = 'Others (non sales)'.
*        ADD 1 TO ld_jumlah.
*    ENDCASE.
*
*--- ENd of Added and commented by Rama

    IF ld_jumlah EQ 1.
      d_bisnisunit = ld_busln.
    ELSE.
      CONCATENATE d_bisnisunit ld_busln INTO d_bisnisunit
                  SEPARATED BY ','.
    ENDIF.
    APPEND r_busln.
  ENDLOOP.

  IF ld_jumlah >= 4.
    d_bisnisunit = 'All'.
  ENDIF.

**Select existing data
  SELECT *
     INTO TABLE t_itab
     FROM zgdtxdt0012
     WHERE bukrs = p_bukrs AND
           brnch = p_brnch AND
           busln IN s_busln AND
           masatx = p_masatx.

*if found, show the data in report, if not find it
  IF NOT t_itab[] IS INITIAL.
    t_itab-userid = sy-uname.

****Commented out by Rahmadi --- HAS IT TO BE HARDCODED TO IDR???
*    t_itab-waers = 'IDR'.      "Pajak Jadi Wajib IDR
****end of comment
    t_itab-flag_data = '1'.    "flag for data from  Table 12 (existing)
    MODIFY t_itab TRANSPORTING userid
*                               waers   "commented out by Rahmadi
                               flag_data
              WHERE flag_data NE '1' OR userid NE sy-uname.

*add Fakturno & Fakdat, cause both are Primary Key, Can change in ALV
    LOOP AT t_itab.
*     DEQUEUE_EZGDTXdt0012
*     ENQUEUE_EZGDTXdt0012
*      CALL FUNCTION 'ENQUEUE_EZGDTXdt0012'
*          EXPORTING
*               MODE_ZGDTXdt0012 = 'E'
*               MANDT              = SY-MANDT
*               BUKRS              = t_itab-bukrs
*               brnch              = t_itab-brnch
*               busln              = t_itab-busln
*               BELNR              = t_itab-belnr
*               BUDAT              = t_itab-budat
*               BUZEI              = t_itab-buzei
*               GJAHR              = t_itab-gjahr
*               FAKTURNO           = t_itab-fakturno
*               FAKDAT             = t_itab-fakdat
*               MASATX             = t_itab-masatx
*          EXCEPTIONS
*               FOREIGN_LOCK       = 1
*               SYSTEM_FAILURE     = 2
*               OTHERS             = 3
*                .
*      IF sy-subrc <> 0.
*         delete t_itab.
*         continue.
*      ENDIF.

      t_itab-fakturno_old = t_itab-fakturno.
      t_itab-fakdat_old   = t_itab-fakdat.

      IF t_itab-fakturno_new IS NOT INITIAL.
        t_itab-fakturno = t_itab-fakturno_new.
*        t_itab-fakdat   = t_itab-fakdat_new.
      ENDIF.

      IF t_itab-fakdat(4) GT 2006.
        lv_length = strlen( t_itab-fakturno ).
        IF lv_length = 17.
          WRITE t_itab-fakturno TO t_itab-fakturno_new1 USING EDIT MASK '__.__.__-___.________'.
        ELSE.
          CONCATENATE t_itab-fakturno(3) '.' t_itab-fakturno+3(3) '-'
                      t_itab-fakturno+6(2) '.' t_itab-fakturno+8(8)
          INTO t_itab-fakturno_new1.
        ENDIF.
      ELSE.
        t_itab-fakturno_new1 = t_itab-fakturno.
      ENDIF.

      t_itab-fakturno_new = t_itab-fakturno.
      t_itab-qty          = t_itab-itqty.
      MODIFY t_itab.
    ENDLOOP.

    t_itab1[] = t_itab[].

  ENDIF.

ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_TABLE
*&---------------------------------------------------------------------*
FORM f_lock_table USING    fu_bukrs
                           fu_brnch
                  CHANGING fc_error
                           fc_posting.

  DATA: ld_uname   LIKE sy-uname,
        ld_tabname LIKE dd02l-tabname.
  TABLES user_addr.

***modified by Rahmadi
*  CONCATENATE 'ZGDTXdt0012' fu_bukrs fu_brnch
*              INTO ld_tabname.
*
*  CALL FUNCTION 'ZPYGLFC_GENERAL_LOCK'
*       EXPORTING
*            fi_objnam        = ld_tabname
*            fi_param         = 'X'
*       EXCEPTIONS
*            object_is_locked = 1
*            OTHERS           = 2.

  CALL FUNCTION 'ENQUEUE_EZGDTXDT0012'
    EXPORTING
      mode_zgdtxdt0012 = 'E'
      mandt            = sy-mandt
      bukrs            = fu_bukrs
      brnch            = fu_brnch
*     BUSLN            =
*     BELNR            =
*     BUDAT            =
*     BUZEI            =
*     GJAHR            =
*     FAKTURNO         =
*     FAKDAT           =
*     MASATX           =
*     X_BUKRS          = ' '
*     X_BRNCH          = ' '
*     X_BUSLN          = ' '
*     X_BELNR          = ' '
*     X_BUDAT          = ' '
*     X_BUZEI          = ' '
*     X_GJAHR          = ' '
*     X_FAKTURNO       = ' '
*     X_FAKDAT         = ' '
*     X_MASATX         = ' '
*     _SCOPE           = '2'
*     _WAIT            = ' '
*     _COLLECT         = ' '
    EXCEPTIONS
      foreign_lock     = 1
      system_failure   = 2
      OTHERS           = 3.
***end of modification
  fc_error = 0.
  IF sy-subrc <> 0.
    fc_error = 3.

    CLEAR user_addr.
    SELECT SINGLE name_first name_last
      FROM user_addr
      INTO (user_addr-name_first, user_addr-name_last)
      WHERE bname = sy-msgv1.


    CONCATENATE sy-msgv1
                 user_addr-name_first
                 user_addr-name_last
                 '!'
                 INTO fc_posting SEPARATED BY space.
  ENDIF.

ENDFORM.                    " F_LOCK_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_SAP_DATA
*&---------------------------------------------------------------------*
FORM f_sap_data.
  DATA : BEGIN OF lt_lfa1 OCCURS 0,
           lifnr  LIKE lfa1-lifnr,
           name1  LIKE lfa1-name1,
           street LIKE lfa1-stras,
           stceg  LIKE lfa1-stceg,
           xcpdk  LIKE lfa1-xcpdk,
           anred  LIKE lfa1-anred,
           stcd1  LIKE lfa1-stcd1,
           stcd2  LIKE lfa1-stcd2,
         END OF lt_lfa1.

  DATA : BEGIN OF lt_kna1 OCCURS 0,
           kunnr  LIKE kna1-kunnr,
           name1  LIKE kna1-name1,
           street LIKE kna1-stras,
           stceg  LIKE kna1-stceg,
           xcpdk  LIKE kna1-xcpdk,
           anred  LIKE kna1-anred,
           stcd1  LIKE kna1-stcd1,
           stcd2  LIKE kna1-stcd2,
         END OF lt_kna1.

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

  DATA : lt_bseg  LIKE t_bseg   OCCURS 0 WITH HEADER LINE.

  DATA BEGIN OF lt_12 OCCURS 0.
  DATA: bukrs LIKE zgdtxdt0012-bukrs,
        belnr LIKE zgdtxdt0012-belnr,
        gjahr LIKE zgdtxdt0012-gjahr.
  DATA END OF lt_12.

  DATA: lf_masatx(6),
        lf_date LIKE sy-datum.

*range for document no
  RANGES : r_belnr FOR bsis-belnr.

  REFRESH : r_belnr.
  r_belnr-sign = 'I'.
  IF d_belnrto NE space.
    r_belnr-option = 'BT'.
  ELSE.
    r_belnr-option = 'EQ'.
  ENDIF.

  MOVE d_belnrfrom TO r_belnr-low.
  MOVE d_belnrto   TO r_belnr-high.
  APPEND r_belnr.

*Find Reversed Document and posting date
  SELECT bukrs
         belnr
         gjahr
         stblg
         budat
         waers
         monat
         bktxt
   FROM bkpf
   INTO TABLE t_bkpf
   WHERE bukrs = p_bukrs AND
         belnr IN s_beln AND    "Fikk 21/06/2004
         budat IN s_budat AND   "Fikk 21/06/2004
*         gjahr = d_gjahr.
         gjahr = d_gjahr2. " AND   "Fikk 21/06/2004
***added for Tempo
*         bktxt IN s_bktxt.
***end of addition

  SORT t_bkpf BY bukrs belnr gjahr.

***added for Tempo
**Filter out documents out of selected tax period
**since the FP date is stored in Doc.header txt (BKTXT)
  BREAK bcrmd.
  DELETE t_bkpf WHERE bktxt CN '1234567890. ' OR
*                      ( bktxt+3(2) <> p_masatx+4(2) OR
*                        bktxt+6(4) <> p_masatx+0(4) ).
*                      ( budat+4(2) <> p_masatx+4(2) OR
*                        budat+0(4) <> p_masatx+0(4) ).
***Exclude documents with FP date earlier than selected tax period
                      ( ( bktxt+3(2) > p_masatx+4(2) AND
                          bktxt+6(4) = p_masatx+0(4) ) OR
                        ( bktxt+3(2) > p_masatx+4(2) AND
                           bktxt+6(4) > p_masatx+0(4) ) ).

* Delete Document Header Text ( 3 bulan )
  lf_masatx = p_masatx(6).
  CONCATENATE lf_masatx '01' INTO lf_date.
  DO 3 TIMES.
    CONCATENATE lf_date(6) '01' INTO lf_date.
    lf_date = lf_date - 1.
  ENDDO.
  lf_masatx = lf_date(6).

  IF p_bukrs NE '8210' AND
    p_bukrs NE '8040'.
    DELETE t_bkpf WHERE ( ( bktxt+3(2) < lf_masatx+4(2)   AND
                            bktxt+6(4) = lf_masatx+0(4) ) OR
                          ( bktxt+3(2) < lf_masatx+4(2)   AND
                            bktxt+6(4) < lf_masatx+0(4) ) ).
  ENDIF.
***

* Add checking for tax period 17/01/2006.
*  DELETE t_bkpf WHERE bktxt+4(6) >= p_masatx(6).

* document header text HARUS format tanggal DD.MM.YYYY
  DELETE t_bkpf WHERE bktxt+10 NE space.
  DELETE t_bkpf WHERE bktxt(2)    NS '1234567890' AND
                      bktxt+3(2)  NS '1234567890' AND
                      bktxt+6(4)  NS '1234567890' AND
                      ( bktxt+2(1)  NE '.'        OR
                        bktxt+5(1)  NE '.' ).

* Add checking for tax period 17/01/2006.
  DELETE t_bkpf WHERE ( ( bktxt+3(2) GT p_masatx+4(2)   AND
                          bktxt+6(4) EQ p_masatx+0(4) ) OR
                        ( bktxt+3(2) LE p_masatx+4(2)   AND
                          bktxt+6(4) GT p_masatx+0(4) ) ).

***Check against data in ZGDTXDT0012
  CHECK NOT t_bkpf[] IS INITIAL.
  SELECT bukrs belnr gjahr
         INTO TABLE lt_12
         FROM zgdtxdt0012
         FOR ALL ENTRIES IN t_bkpf
         WHERE bukrs = t_bkpf-bukrs AND
               belnr = t_bkpf-belnr AND
               gjahr = t_bkpf-gjahr.
  IF sy-subrc = 0.
    SORT lt_12 BY bukrs belnr gjahr.
    LOOP AT t_bkpf.
      READ TABLE lt_12 WITH KEY bukrs = t_bkpf-bukrs
                                belnr = t_bkpf-belnr
                                gjahr = t_bkpf-gjahr
                                BINARY SEARCH.
      IF sy-subrc = 0.
        DELETE t_bkpf.
      ENDIF.
    ENDLOOP.
  ENDIF.
***end of Tempo addition

  d_error = 2.
  CHECK NOT t_bkpf[] IS INITIAL.
  d_error = 0.

* Find Acc Document Credit
  SELECT bukrs
         belnr
         gjahr
         buzei
         buzid  "added by Rahmadi
         wrbtr
         dmbtr  "added by Rahmadi
         fwbas
         hwbas  "added by Rahmadi
         zfbdt
         zuonr
         sgtxt
         augdt
         augbl
         menge
         meins
         hkont
         lifnr
         bschl
         gsber
         shkzg
         valut
         kunnr
         xref1
         mwskz  "added by Rahmadi
         koart  "added by Budi ( 06/10/2005 )
     INTO CORRESPONDING FIELDS OF TABLE t_bseg
     FROM bseg
     FOR ALL ENTRIES IN t_bkpf       "Fikk 21/06/2004
     WHERE bukrs = t_bkpf-bukrs AND  "Fikk 21/06/2004
           belnr = t_bkpf-belnr AND   "Fikk 21/06/2004
           gjahr = t_bkpf-gjahr  AND    "Fikk 21/06/2004
           hkont NE space.
*           belnr in r_belnr and    "Fikk 21/06/2004
***modified by Rahmadi
*           gsber = p_gsber  AND
***end of modification

  d_error = 2.
  CHECK NOT t_bseg[] IS INITIAL.
  d_flg = 'X'.

***added by Rahmadi
***Put Company specific logic to determine branch
***in below User Exit
  PERFORM f_select_branch TABLES t_bseg
                          USING p_bukrs
                                p_brnch.
***end of addition
  d_error = 0.

  SORT t_bseg BY bukrs belnr gjahr hkont.

  REFRESH : t_bseg1, lt_bseg, lt_lfa1, lt_bsec.
  t_bseg1[] = lt_bseg[] = t_bseg[].

***added by Rahmadi
  t_bseg2[] = t_bseg[].
  DELETE t_bseg2 WHERE kunnr EQ space.
  IF NOT t_bseg2[] IS INITIAL.
    SELECT kunnr
           name1
           stras
           stceg
           xcpdk
           anred
           stcd1
           stcd2
      INTO TABLE lt_kna1
    FROM kna1
    FOR ALL ENTRIES IN t_bseg2
    WHERE kunnr = t_bseg2-kunnr.

    SORT lt_kna1 BY kunnr.

    DELETE ADJACENT DUPLICATES FROM lt_kna1 COMPARING kunnr.

*One time Customer
    SELECT bukrs
           belnr
           gjahr
           buzei
           name1
           stras
           stcd1
           stcd2
     FROM bsec
     INTO TABLE lt_bsec
     WHERE bukrs = p_bukrs  AND
*           belnr in r_belnr and
*           gjahr = d_gjahr.
         belnr IN s_beln AND  "Fikk 21/06/2004
         gjahr = d_gjahr2.         "Fikk 21/06/2004

    SORT lt_bsec BY bukrs belnr gjahr.
*End of add.

* Get ppn for Dragon Glory
    IF p_bukrs EQ '8050'.
      SELECT bukrs belnr gjahr buzei shkzg hwbas fwbas hwste fwste
        FROM bset
        INTO TABLE t_bset
        FOR ALL ENTRIES IN t_bkpf
        WHERE bukrs = t_bkpf-bukrs AND
              belnr = t_bkpf-belnr AND
              gjahr = t_bkpf-gjahr.
    ENDIF.

    CLEAR sy-tabix.
    LOOP AT t_bseg2.
***bugfix by Rahmadi (Tempo)
      READ TABLE t_bkpf WITH KEY bukrs = t_bseg2-bukrs
                                 belnr = t_bseg2-belnr
                                 gjahr = t_bseg2-gjahr.
      t_bseg2-waers = t_bkpf-waers.
***end of bugfix
      READ TABLE lt_kna1 WITH KEY kunnr = t_bseg2-kunnr
                         BINARY SEARCH.

      IF sy-subrc = 0.
        IF lt_lfa1-xcpdk EQ 'X'.
          READ TABLE lt_bsec WITH KEY bukrs = t_bseg2-bukrs
                                      belnr = t_bseg2-belnr
                                      gjahr = t_bseg2-gjahr.
          IF sy-subrc = 0.
            t_bseg2-name1  = lt_bsec-name1.
            t_bseg2-street = lt_bsec-stras.
          ENDIF.
        ELSE.
***Tempo: no need to concatenate TITLE to NAME
*          CONCATENATE lt_kna1-anred
*                      lt_kna1-name1 INTO t_bseg2-name1
*                                    SEPARATED BY space.
          t_bseg2-name1  = lt_kna1-name1.
          t_bseg2-street = lt_kna1-street.
          t_bseg2-stceg  = lt_kna1-stceg.
***added for Tempo
          t_bseg2-stcd1 = lt_kna1-stcd1.
          t_bseg2-stcd2 = lt_kna1-stcd2.
***end of Tempo addition
        ENDIF.

        MODIFY t_bseg2. "INDEX sy-tabix TRANSPORTING name1 street stceg.
      ENDIF.
      CLEAR t_bseg2.
    ENDLOOP.

  ENDIF.
***end of addition

* penambahan logic untuk menampilkan zuonr
  LOOP AT lt_bseg.
    IF lt_bseg-bschl EQ '31' AND
      lt_bseg-shkzg EQ 'H'.
      MODIFY lt_bseg TRANSPORTING zuonr
                     WHERE belnr EQ lt_bseg-belnr AND
                           hkont IN r_busln.
    ENDIF.
  ENDLOOP.

*delete bseg where not in Range GL Account.
*Diatas pas select tidak bisa soalnya, untuk mencari field Lifnr
  REFRESH t_bseg.
  LOOP AT lt_bseg.
    CHECK lt_bseg-hkont IN r_busln.
    MOVE-CORRESPONDING lt_bseg TO t_bseg.
***bugfix by Rahmadi (Tempo)
    READ TABLE t_bkpf WITH KEY bukrs = lt_bseg-bukrs
                               belnr = lt_bseg-belnr
                               gjahr = lt_bseg-gjahr.
    t_bseg-waers = t_bkpf-waers.
    t_bseg-bktxt = t_bkpf-bktxt.
***end of bugfix
    APPEND t_bseg.
    CLEAR t_bseg.
  ENDLOOP.

**changed by Rahmadi, requested by Darman, for MKM 02/03/2004
**for determining vendor line item to be considered
*  DELETE t_bseg1 WHERE lifnr EQ space.
  DELETE t_bseg1 WHERE NOT ( lifnr NE space AND buzid EQ space ).
**end of change

  IF NOT t_bseg1[] IS INITIAL.
    SELECT lifnr
           name1
           stras
           stceg
           xcpdk
           anred
           stcd1
           stcd2
      INTO TABLE lt_lfa1
    FROM lfa1
    FOR ALL ENTRIES IN t_bseg1
    WHERE lifnr = t_bseg1-lifnr.

    SORT lt_lfa1 BY lifnr.

    DELETE ADJACENT DUPLICATES FROM lt_lfa1 COMPARING lifnr.

*One time Vendor
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
     WHERE bukrs = p_bukrs  AND
*           belnr in r_belnr and
*           gjahr = d_gjahr.
         belnr IN s_beln AND  "Fikk 21/06/2004
         gjahr = d_gjahr2.         "Fikk 21/06/2004

    SORT lt_bsec BY bukrs belnr gjahr.
*End of add.

* Get ppn for Dragon Glory
    IF p_bukrs EQ '8050'.
      SELECT bukrs belnr gjahr buzei shkzg hwbas fwbas hwste fwste
        FROM bset
        INTO TABLE t_bset
        FOR ALL ENTRIES IN t_bkpf
        WHERE bukrs = t_bkpf-bukrs AND
              belnr = t_bkpf-belnr AND
              gjahr = t_bkpf-gjahr.
    ENDIF.

    CLEAR sy-tabix.
    LOOP AT t_bseg1.
***bugfix by Rahmadi (Tempo)
      READ TABLE t_bkpf WITH KEY bukrs = t_bseg1-bukrs
                                 belnr = t_bseg1-belnr
                                 gjahr = t_bseg1-gjahr.
      t_bseg1-waers = t_bkpf-waers.
***end of bugfix
      READ TABLE lt_lfa1 WITH KEY lifnr = t_bseg1-lifnr
                       BINARY SEARCH.

      IF sy-subrc = 0.
        IF lt_lfa1-xcpdk EQ 'X'.
          READ TABLE lt_bsec WITH KEY bukrs = t_bseg1-bukrs
                                      belnr = t_bseg1-belnr
                                      gjahr = t_bseg1-gjahr.
          IF sy-subrc = 0.
            t_bseg1-name1  = lt_bsec-name1.
            t_bseg1-street = lt_bsec-stras.
***added for Tempo
            t_bseg1-stcd1 = lt_bsec-stcd1.
            t_bseg1-stcd2 = lt_bsec-stcd2.
            IF p_bukrs EQ '8230' OR
              p_bukrs EQ '8050'.
              CALL FUNCTION 'ZF_NPWP_MODIFICATION'
                EXPORTING
                  npwp_in  = lt_bsec-bkref
                IMPORTING
                  npwp_out = t_bseg1-stceg.
            ENDIF.
***end of Tempo addition
          ENDIF.
        ELSE.
***Tempo: no need to concatenate TITLE to NAME
*          CONCATENATE lt_lfa1-anred
*                      lt_lfa1-name1 INTO t_bseg1-name1
*                                    SEPARATED BY space.
          t_bseg1-name1  = lt_lfa1-name1.
          t_bseg1-street = lt_lfa1-street.
          t_bseg1-stceg  = lt_lfa1-stceg.
***added for Tempo
          t_bseg1-stcd1 = lt_lfa1-stcd1.
          t_bseg1-stcd2 = lt_lfa1-stcd2.
***end of Tempo addition
        ENDIF.

        MODIFY t_bseg1. "INDEX sy-tabix TRANSPORTING name1 street stceg.
      ENDIF.
      CLEAR t_bseg1.
    ENDLOOP.
  ENDIF.

  PERFORM f_get_main_data.

ENDFORM.                    " F_SAP_DATA


*&---------------------------------------------------------------------*
*&      Form  F_GET_MAIN_DATA
*&---------------------------------------------------------------------*
FORM f_get_main_data.
  DATA: lines LIKE tline OCCURS 0 WITH HEADER LINE,
        name  TYPE tdobname.

  DATA : ld_posting(6) TYPE c.

  DATA: BEGIN OF lt_zgdtxdt0015 OCCURS 0.
          INCLUDE STRUCTURE zgdtxdt0015.
        DATA: END OF lt_zgdtxdt0015.
  DATA lw_bseg LIKE t_bseg.

  DATA: ld_len    TYPE i,
        lv_length TYPE i.

  RANGES: lr_setname  FOR setleaf-setname.
  RANGES: lr_bkp  FOR bseg-hkont,
          lr_jkp  FOR bseg-hkont.

  DATA: BEGIN OF lt_setleaf OCCURS 0,
          setname TYPE setleaf-setname,
          valfrom TYPE setleaf-valfrom,
          valto   TYPE setleaf-valto,
        END OF lt_setleaf.

  SELECT *
   INTO TABLE lt_zgdtxdt0015
   FROM zgdtxdt0015.

*  SORT t_bsis BY bukrs gjahr brnch hkont.
  SORT t_bseg1 BY bukrs gjahr belnr.

***added by Rahmadi
  SORT t_bseg2 BY bukrs gjahr belnr.
  SORT t_bseg BY bukrs gjahr belnr.
***end of addition

  IF p_bukrs EQ '8050'.

    lr_setname-low      = 'GL_ACCOUNT_BKP'.
    lr_setname-sign     = 'I'.
    lr_setname-option   = 'EQ'.
    APPEND lr_setname.
    lr_setname-low      = 'GL_ACCOUNT_JKP'.
    lr_setname-sign     = 'I'.
    lr_setname-option   = 'EQ'.
    APPEND lr_setname.

    SELECT setname valfrom valto
      FROM setleaf
      INTO TABLE lt_setleaf
      WHERE setname IN lr_setname.
    LOOP AT lt_setleaf.
      CASE lt_setleaf-setname.
        WHEN 'GL_ACCOUNT_BKP'.
          lr_bkp-low      = lt_setleaf-valfrom.
          lr_bkp-high     = lt_setleaf-valto.
          lr_bkp-sign     = 'I'.
          lr_bkp-option   = 'BT'.
          APPEND lr_bkp.
        WHEN 'GL_ACCOUNT_JKP'.
          lr_jkp-low      = lt_setleaf-valfrom.
          lr_jkp-high     = lt_setleaf-valto.
          lr_jkp-sign     = 'I'.
          lr_jkp-option   = 'BT'.
          APPEND lr_jkp.
      ENDCASE.
    ENDLOOP.
  ENDIF.

  LOOP AT t_bseg.
    CLEAR : ld_posting,
            t_itab.

    t_itab-bukrs    = t_bseg-bukrs.
    t_itab-brnch    = t_bseg-brnch.
    t_itab-belnr    = t_bseg-belnr.
    t_itab-gjahr    = t_bseg-gjahr.

***added for Tempo
*---Add HKONT to determine Local/Import Account
    t_itab-hkont = t_bseg-hkont.
***end of Tempo addition

***removed for Tempo
*    t_itab-fakturno = t_bseg-zuonr.
***moved further down after get vendor/cust data
***end of Tempo removal

***modified by Rahmadi
*    IF t_bseg-valut IS INITIAL.
*      t_itab-fakdat   = ''.
*    ELSE.
*      t_itab-fakdat   = t_bseg-valut.
*    ENDIF.

***modified for Tempo
*    IF t_bseg-xref1 IS INITIAL.
*      t_itab-fakdat   = ''.
*    ELSE.
*      t_itab-fakdat   = t_bseg-xref1.
*    ENDIF.

****Get Custom Faktur pajak date & period from User exit
    CALL FUNCTION 'Z_GDTXFC_EXIT_VATIN_DATE'
      EXPORTING
        fi_bseg   = t_bseg
      IMPORTING
        fe_fakdat = t_itab-fakdat
        fe_masatx = t_itab-masatx.
    t_itab-masatx   = p_masatx.
*{   REPLACE        P01K900131                                        1
*\    t_itab-yeartx   = t_itab-masatx+(4).
    t_itab-yeartx   = t_itab-masatx(4). "change by sap_dev04 26.03.2007
*}   REPLACE
***end of Tempo modification
***end of modification
***modified by Rahmadi
*    t_itab-fakppn   = t_bseg-wrbtr.

* 18/01/2006
    IF t_bseg-shkzg EQ 'H'.
      t_bseg-dmbtr = t_bseg-dmbtr * -1.
    ENDIF.
    t_itab-fakppn   = t_bseg-dmbtr.
***end of modification
    IF t_bseg-bukrs EQ '8230' OR
      t_bseg-bukrs EQ '8050'.
      CONCATENATE t_bseg-bukrs t_bseg-belnr t_bseg-gjahr t_bseg-buzei INTO name.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                      = '0001'
          language                = sy-langu
          name                    = name
          object                  = 'DOC_ITEM'
        TABLES
          lines                   = lines
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.
      READ TABLE lines INDEX 1.
      IF sy-subrc EQ 0.
        t_itab-item   = lines-tdline.
      ELSE.
        t_itab-item     = t_bseg-sgtxt.
      ENDIF.
    ELSE.
      t_itab-item     = t_bseg-sgtxt.
    ENDIF.
***modified by Rahmadi
*    t_itab-itamt    = t_bseg-fwbas.
*    IF t_bseg-hwbas = 0.
********** Modified by sukardi (14-09-2005)
********** intruksi by Rahmadi Req. By Tavid
***** Perubahan dasar pengenaan Pajak untuk vat in
*    PERFORM f_calc_dpp USING    t_bseg
*                       CHANGING t_bseg-hwbas.
********** End of Modified by sukardi (14-09-2005)
*    ENDIF.
********** Modified by sukardi (14-09-2005)
********** intruksi by Rahmadi Req. By Tavid
*    t_itab-itamt    = t_bseg-hwbas.
    t_itab-itamt    = 1.
********** End of Modified by sukardi (14-09-2005)
***end of modification
    IF t_bseg-bukrs EQ '8230' OR
      t_bseg-bukrs EQ '8050'.
      t_itab-meins    = t_bseg-meins.
    ENDIF.
    t_itab-itqty    = t_bseg-menge.
    t_itab-qty      = t_bseg-menge.
    t_itab-buzei = t_bseg-buzei.
    t_itab-userid   = sy-uname.
    t_itab-indicator = 1.      "1 -> New Record
    t_itab-flag_data = '3'.    " Flag New record in ALV

*Find Credit and posting date, Currency
    READ TABLE t_bkpf WITH KEY bukrs = t_bseg-bukrs
                               belnr = t_bseg-belnr
                               gjahr = t_bseg-gjahr
                  BINARY SEARCH.
    IF sy-subrc = 0.
      CONCATENATE t_bkpf-gjahr t_bkpf-monat INTO ld_posting.

***modified by Rahmadi -- Amount must be shown in Local Currency
*      t_itab-waers = t_bkpf-waers.
      t_itab-waers = 'IDR'.
***end of modification
      t_itab-budat = t_bkpf-budat.
      IF p_bukrs EQ '8050'.
        PERFORM f_get_credit CHANGING t_itab-credit.
      ELSE.
        IF t_bkpf-stblg NE space.
          t_itab-credit = 'B'.
        ELSE.
          IF t_bseg-shkzg = 'S'.
            t_itab-credit = 'C'.
          ENDIF.
          IF t_bseg-shkzg = 'H'.
            t_itab-credit = 'R'.
***modified by Rahmadi
*          t_itab-fakppn   = t_bseg-wrbtr * -1.
*****          t_itab-fakppn   = t_bseg-dmbtr * -1. "18/01/2006  DIK
*****          t_itab-itamt    = t_itab-itamt * -1. "18/01/2006  DIK
*          t_itab-itamt    = t_bseg-fwbas * -1.
********** Modified by Budi (15-09-2005)
********** intruksi by Rahmadi Req. By Tavid
*          t_itab-itamt    = t_bseg-hwbas * -1.
********** End of Modified by sukardi (15-09-2005)
***end of modification
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

*Find Vendor
    READ TABLE t_bseg1 WITH KEY bukrs = t_bseg-bukrs
                                gjahr = t_bseg-gjahr
*                                brnch = t_bseg-brnch
                                belnr = t_bseg-belnr
               BINARY SEARCH.
    IF sy-subrc = 0.
      t_itab-no_bh = t_bseg1-augbl.
      t_itab-tg_bh = t_bseg1-augdt.
      t_itab-lifnr = t_bseg1-lifnr.
      t_itab-name  = t_bseg1-name1.
      t_itab-adrnr = t_bseg1-street.
      t_itab-npwp  = t_bseg1-stceg.
***added for Tempo -- for displaying GSBER
      t_itab-gsber = t_bseg1-gsber.
***end of tempo addition

** added by Budi Req. by SJT (06/10/2005)
      IF t_bseg-koart = 'S' AND
         t_bseg-mwskz = space.
*        IF t_bseg-shkzg EQ 'H'.
*          t_itab-itamt = t_bseg-dmbtr / ( 10 / 100 ) * -1.
*        ELSE.

        PERFORM f_tax_calc USING '' p_masatx t_bseg-dmbtr 'J'
                           CHANGING t_itab-itamt.

*        t_itab-itamt = t_bseg-dmbtr / ( 10 / 100 ).
*        ENDIF.
      ELSE.
** End added by Budi Req. by SJT (06/10/2005)

        IF p_bukrs EQ '8050'.
          PERFORM f_calc_dpp8050 USING t_bseg
                                 CHANGING t_bseg-itamt t_itab-fakppn.
********** Modified by Budi (15-09-2005)
********** intruksi by Rahmadi Req. By Tavid
        ELSE.
          PERFORM f_calc_dpp USING    t_bseg
                             CHANGING t_bseg-itamt.
        ENDIF.

        t_itab-itamt = t_itab-itamt * t_bseg-itamt.
********** End of Modified by Budi (15-09-2005)

** added by Budi Req. by SJT (06/10/2005)
      ENDIF.
** End added by Budi Req. by SJT (06/10/2005)

      lw_bseg = t_bseg1.
    ELSE.
      READ TABLE t_bseg2 WITH KEY bukrs = t_bseg-bukrs
                                  gjahr = t_bseg-gjahr
*                                brnch = t_bseg-brnch
                                  belnr = t_bseg-belnr
                         BINARY SEARCH.
      IF sy-subrc = 0.
        t_itab-no_bh = t_bseg2-augbl.
        t_itab-tg_bh = t_bseg2-augdt.
        t_itab-lifnr = t_bseg2-kunnr.
        t_itab-name  = t_bseg2-name1.
        t_itab-adrnr = t_bseg2-street.
        t_itab-npwp  = t_bseg2-stceg.
***added for Tempo -- for displaying GSBER
        t_itab-gsber = t_bseg2-gsber.
***end of tempo addition

** added by Budi Req. by SJT (06/10/2005)
        IF t_bseg-koart = 'S' AND
           t_bseg-mwskz = space.
*          IF t_bseg-shkzg EQ 'H'.
*            t_itab-itamt = t_bseg-dmbtr / ( 10 / 100 ) * -1.
*          ELSE.
          PERFORM f_tax_calc USING '' p_masatx t_bseg-dmbtr 'J'
                             CHANGING t_itab-itamt.

*          t_itab-itamt = t_bseg-dmbtr / ( 10 / 100 ).
*          ENDIF.
        ELSE.
** End added by Budi Req. by SJT (06/10/2005)

          IF p_bukrs EQ '8050'.
            PERFORM f_calc_dpp8050 USING t_bseg
                                   CHANGING t_bseg-itamt t_itab-fakppn.
          ELSE.
********** Modified by Budi (15-09-2005)
********** intruksi by Rahmadi Req. By Tavid
            PERFORM f_calc_dpp USING    t_bseg2
                               CHANGING t_bseg2-itamt.
          ENDIF.
          t_itab-itamt = t_itab-itamt * t_bseg2-itamt.
********** End of Modified by Budi (15-09-2005)

** added by Budi Req. by SJT (06/10/2005)
        ENDIF.
** End added by Budi Req. by SJT (06/10/2005)

        lw_bseg = t_bseg2.
      ENDIF.
    ENDIF.

***added for Tempo
****Get custom Faktur pajak number stored in Accounting doc
    CALL FUNCTION 'Z_GDTXFC_EXIT_VATIN_NUMBER'
      EXPORTING
        fi_bseg     = t_bseg
        fi_bseg2    = lw_bseg
      IMPORTING
        fe_fakturno = t_itab-fakturno.

    ld_len = strlen( t_bseg-bktxt ).
    ld_len = ld_len - 4.

    IF t_bseg-bktxt+ld_len(4) GT 2006.
      IF NOT t_bseg-zuonr IS INITIAL.
        lv_length = strlen( t_bseg-zuonr ).
        IF lv_length = 17.
          WRITE t_bseg-zuonr TO t_itab-fakturno_new1 USING EDIT MASK '__.__.__-___.________'.
        ELSE.
          CONCATENATE t_bseg-zuonr(3) '.' t_bseg-zuonr+3(3) '-'
                      t_bseg-zuonr+6(2) '.' t_bseg-zuonr+8(8)
          INTO t_itab-fakturno_new1.
        ENDIF.
        t_itab-fakturno_new = t_bseg-zuonr.
      ENDIF.
    ELSE.
      t_itab-fakturno_new1 = t_itab-fakturno.
      t_itab-fakturno_new = t_itab-fakturno.
    ENDIF.

***end of Tempo addition

***Added by Rama
*   get busln for the account
    LOOP AT lt_zgdtxdt0015 WHERE hkontfr <= t_bseg-hkont
                            AND   hkontto >= t_bseg-hkont.
      EXIT.
    ENDLOOP.
    t_itab-busln = lt_zgdtxdt0015-busln.
***end of Addition

*Find Form
    CASE t_itab-credit.
      WHEN 'C' OR 'I' OR 'R'.
        t_itab-form = 'B1'.
      WHEN 'X'.
        t_itab-form = 'B2'.
      WHEN 'D'.
        IF p_bukrs EQ '8050'.
          t_itab-form = 'B3'.
        ELSE.
          t_itab-form = 'B4'.
        ENDIF.
    ENDCASE.

    IF p_bukrs EQ '8050'.
      IF t_bseg-hkont IN lr_bkp.
        APPEND t_itab.
      ELSEIF t_bseg-hkont IN lr_jkp.
        IF t_itab-itqty IS NOT INITIAL.
          APPEND t_itab.
        ENDIF.
      ELSE.
        IF t_itab-itqty IS NOT INITIAL.
          APPEND t_itab.
        ENDIF.
      ENDIF.
    ELSE.
      APPEND t_itab.
    ENDIF.

    CLEAR t_itab.
  ENDLOOP.

  SORT t_itab BY brnch busln belnr budat buzei gjahr
                 masatx indicator.

  IF p_bukrs EQ '8050'.
    DELETE ADJACENT DUPLICATES FROM t_itab COMPARING bukrs
                                                     brnch
                                                     busln
                                                     belnr
                                                     budat
                                                     gjahr
*                                                   fakturno
*                                                   fakdat
                                                     masatx.
  ELSE.
    DELETE ADJACENT DUPLICATES FROM t_itab COMPARING bukrs
                                                     brnch
                                                     busln
                                                     belnr
                                                     budat
                                                     buzei
                                                     gjahr
*                                                   fakturno
*                                                   fakdat
                                                     masatx.
  ENDIF.

  SORT t_itab BY belnr budat fakturno.
ENDFORM.                    " F_GET_MAIN_DATA

*&---------------------------------------------------------------------*
*&      Form  F_TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM f_top_of_page.
  DATA : lt_itab  LIKE t_itab,
         ld_tabix TYPE i,
         ld_butxt LIKE t001-butxt.

  SELECT SINGLE butxt INTO ld_butxt
                      FROM t001
                      WHERE bukrs = p_bukrs.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING ld_butxt.
  PERFORM f_hdr_line2 USING 'Maintain VAT-In Data'.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.

  WRITE : / 'Company Code           : ', p_bukrs,
          / 'Branch                 : ', p_brnch,
***removed by Rahmadi
*          / 'Business Line          : ', d_bisnisunit,
***end of removal
          / 'Posting Period         : ', p_masatx,
          / icon_red_light AS ICON , 'Processed Data',
            icon_green_light AS ICON, 'Data to be processed',
            icon_yellow_light AS ICON, 'Data with errors'.

* Change NO urut if Sorting
  LOOP AT t_itab INTO lt_itab.
    IF lt_itab = t_itab.
      CLEAR ld_tabix.
    ENDIF.
    ADD 1 TO ld_tabix.
    lt_itab-no = ld_tabix.
    MODIFY t_itab FROM lt_itab TRANSPORTING no.
  ENDLOOP.
ENDFORM.                    " F_TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  F_END_OF_LIST
*&---------------------------------------------------------------------*
FORM f_end_of_list.
  DATA : ld_cek(1)    TYPE c VALUE 'X',
         ld_record    TYPE i,
         ld_record1   TYPE i,
         ld_record2   TYPE i,
         ld_record3   TYPE i,
         ld_total(3)  TYPE c,
         ld_merah(3)  TYPE c,
         ld_kuning(3) TYPE c,
         ld_hijau(3)  TYPE c.

  CLEAR : ld_record, ld_merah, ld_kuning, ld_hijau, ld_total,
          ld_record1, ld_record2, ld_record3.

  LOOP AT t_itab.
    CASE t_itab-flag_data.
      WHEN '1'.
        ADD 1 TO ld_record1.
      WHEN '2'.
        ADD 1 TO ld_record2.
      WHEN '3'.
        ADD 1 TO ld_record3.
    ENDCASE.
  ENDLOOP.

  ld_record = ld_record1 + ld_record2 + ld_record3.
  ld_total  = ld_record.
  ld_merah  = ld_record1.
  ld_kuning = ld_record2.
  ld_hijau  = ld_record3.

  WRITE : / 'Legend :',
          / 'B -> Batal', 35 'I -> Import',
          / 'C -> Dapat dikreditkan', 35 'R -> Retur',
          / 'D -> Tidak dapat dikreditkan', 35 'X -> Ditangguhkan',
          / icon_red_light AS ICON , ld_merah,'Records',
            icon_yellow_light AS ICON, ld_kuning,'Records',
            icon_green_light AS ICON, ld_hijau,'Records',
            '=', ld_total, 'Records Display',
          / ld_cek AS CHECKBOX, 'For delete records with red lamp'.

ENDFORM.                    " F_END_OF_LIST



*&---------------------------------------------------------------------*
*&      Form  F_WRITE_DATA
*&---------------------------------------------------------------------*
FORM f_write_data.

  PERFORM f_fieldcats USING :
*    'NO'     ''  space  'NO'          '5'    space 'X'   space ''
*    '' '' ,
    'BELNR'    'BSEG' 'BELNR' 'No.Doc'      '10'   space 'X'  space 'X'
    '' '' '' '',
    'BUDAT'    'BKPF' 'BUDAT' 'Tgl.Doc'     '10'   space 'X'   space ''
    '' '' '' '',
*    'FAKTURNO' 'BSEG' 'ZUONR' 'No. Faktur Pajak'  '17'   'X'   space
*     space '' '' '' '' ''.
    'FAKTURNO_NEW1' '' '' 'No. Faktur Pajak'  '22'   'X'   space
     space '' '' '' '' ''.

  PERFORM f_fieldcats USING :
    'FAKDAT'   'ZGDTXDT0012' 'FAKDAT' 'Tgl. FP'     ''     'X'
     space space ''    '__.__.____' '' '' '',
***added for tempo --- to select GSBER
    'GSBER'    'BSEG' 'GSBER' 'Bus.Area'  '10'   space 'X'  space 'X'
    '' '' '' '',
***end of Tempo addition
    'CREDIT'   space            space   '*' '1' 'X'  space space ''
    '' '' '' '',
    'LIFNR'     'LFA1' 'LIFNR' 'Kode Vendor' '10'   'X'   space space ''
    '' '' '' '',
    'NAME'     'LFA1' 'NAME1' 'Nama Vendor' '40'   'X'   space space ''
    '' '' '' '',
    'NPWP'     'LFA1' 'STCEG' 'NPWP'        '20'   'X'   space space ''
    '' '' '' '',
***modified by Rahmadi
*    'QTY'       'BSEG' 'MENGE' 'Qty'         '6'  'X'   space space ''
*    '' '' '' '',
    'QTY'       'BSEG' 'MENGE' 'Qty'         '6'  'X'   space space ''
    '' '' '' 'MEINS',
    'MEINS'       'ZGDTXDT0012' 'MEINS' 'UOM' '6'  'X'   space space ''
    '' '' '' '',
    'ITEM'     'BSEG' 'SGTXT' 'Nama Barang' '50'   'X'   space space ''
    '' '' '' '',
*    'ITAMT'    'BSEG' 'FWBAS' 'DPP'         space  '' space 'X'   ''
*    '' 'IDR' '' '',
******CHANGE REQUEST 02/10/2003 *******************
*    'ITAMT'    'BSEG' 'HWBAS' 'DPP'         space  '' space 'X'   ''
*    '' '' 'WAERS' '',
    'ITAMT'    'BSEG' 'HWBAS' 'DPP'         space  '' space 'X'   ''
    '' '' 'WAERS' '',
*******END OF CHANGE REQUEST 02/10/2003 ************
*    'FAKPPN'   'BSEG' 'WRBTR' 'PPN'         space  space space 'X'   ''
*    '' 'IDR' '' '',
******CHANGE REQUEST 02/10/2003 *******************
*    'FAKPPN'   'BSEG' 'DMBTR' 'PPN'         space  space space 'X'   ''
*    '' '' 'WAERS' '',
    'FAKPPN'   'BSEG' 'DMBTR' 'PPN'         space  '' space 'X'   ''
    '' '' 'WAERS' '',
*******END OF CHANGE REQUEST 02/10/2003 ************
    'WAERS'   'BSEG' 'WAERS' 'Curr.'         space  space space 'X'   ''
    '' '' '' ''.
***end of modification
***removed by Rahmadi
*    'NO_BH'    'ZGDTXDT0012' 'NO_BH' 'No. Bon Hijau' '15' '' '' '' ''
*    '' '' '' '',
*    'TG_BH'    'ZGDTXDT0012' 'TG_BH' 'Tgl. Bon Hijau' '15' '' '' '' ''
*    '' '' '' ''.
***end of removal

  PERFORM f_build_layout     USING   d_layout.
  PERFORM f_build_sortfield  USING   t_sort[].
  PERFORM f_build_event      TABLES  t_events[].
  PERFORM f_build_print      USING   d_print.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK        = ' '
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
*     I_STRUCTURE_NAME         =
      is_layout                = d_layout
      it_fieldcat              = t_fieldcat[]
*     IT_EXCLUDING             =
*     IT_SPECIAL_GROUPS        =
      it_sort                  = t_sort[]
*     IT_FILTER                =
*     IS_SEL_HIDE              =
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = d_variant
      it_events                = t_events[]
*     IT_EVENT_EXIT            =
      is_print                 = d_print
*     IS_REPREP_ID             =
*     I_SCREEN_START_COLUMN    = 0
*     I_SCREEN_START_LINE      = 0
*     I_SCREEN_END_COLUMN      = 0
*     I_SCREEN_END_LINE        = 0
*     I_BYPASSING_BUFFER       =
*     I_BUFFER_ACTIVE          =
*      IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
*     ES_EXIT_CAUSED_BY_USER   =
    TABLES
      t_outtab                 = t_itab[]
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

ENDFORM.                    " F_WRITE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATS
*&---------------------------------------------------------------------*
FORM f_fieldcats USING fu_fname
                       fu_reftb
                       fu_reffname
                       fu_text
                       fu_len
                       fu_input
                       fu_key
                       fu_sum
                       fu_spot
                       fu_edit_mask
                       fu_curr
***added by Rahmadi
                       fu_cfname
                       fu_qfname.
***end of addition

  DATA : lt_fieldcat TYPE slis_fieldcat_alv.
  lt_fieldcat-fieldname      = fu_fname.
  lt_fieldcat-ref_tabname    = fu_reftb.
  lt_fieldcat-ref_fieldname  = fu_reffname.
  lt_fieldcat-seltext_l      = fu_text.
  lt_fieldcat-reptext_ddic   = fu_text.
  lt_fieldcat-outputlen      = fu_len.
  lt_fieldcat-input          = fu_input.
  lt_fieldcat-key            = fu_key.
  lt_fieldcat-do_sum         = fu_sum.
  lt_fieldcat-hotspot        = fu_spot.
  lt_fieldcat-edit_mask      = fu_edit_mask.
  lt_fieldcat-currency       = fu_curr.
***added by Rahmadi
  lt_fieldcat-cfieldname     = fu_cfname.
  lt_fieldcat-qfieldname     = fu_qfname.
***end of addition
  APPEND lt_fieldcat TO t_fieldcat.
  CLEAR: lt_fieldcat.

ENDFORM.                    " F_FIELDCATS

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout USING p_layout TYPE slis_layout_alv.
  p_layout-zebra             = 'X'.
  p_layout-group_change_edit = 'X'.
  p_layout-window_titlebar   = ' '.
  p_layout-totals_text       = 'Total'.
  p_layout-box_fieldname     = 'CEK'.
  p_layout-lights_fieldname  = 'FLAG_DATA'.
  p_layout-lights_condense   = 'X'.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORTFIELD
*&---------------------------------------------------------------------*
FORM f_build_sortfield USING  p_t_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'BELNR'.
  ld_sort-up      = 'X'.
  APPEND ld_sort TO p_t_sort.
ENDFORM.                    " F_BUILD_SORTFIELD

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT
*&---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.

  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.
  CLEAR ft_events.

  ft_events-name = slis_ev_end_of_list.
  ft_events-form = 'F_END_OF_LIST'.
  APPEND ft_events.
  CLEAR ft_events.

ENDFORM.                    " F_BUILD_EVENT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_PRINT
*&---------------------------------------------------------------------*
FORM f_build_print USING p_print TYPE slis_print_alv.
  d_print-no_print_listinfos = 'X'.
ENDFORM.                    " F_BUILD_PRINT

*&---------------------------------------------------------------------*
*&      Form  F_SET_PF_STATUS
*&---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
*  DATA: lt_status LIKE LINE OF rt_extab.
  sy-lsind = 0.
  SET PF-STATUS 'STANDARD' EXCLUDING rt_extab.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA : ld_count  TYPE i,
         ld_count1 TYPE i.

  ld_count  = 0.
  ld_count1 = 0.

  LOOP AT t_itab WHERE cek = 'X' AND flag_data = '1'.
    ADD 1 TO ld_count.
    EXIT.
  ENDLOOP.

  LOOP AT t_itab WHERE cek = 'X' AND flag_data = '3'.
    ADD 1 TO ld_count1.
    EXIT.
  ENDLOOP.

  sy-lsind = 0.
  CASE fu_ucomm.
    WHEN 'PROC'.
      PERFORM f_cek_flag_bfrsave.
      PERFORM f_to_txdt0012.
      fu_selfield-refresh = 'X'.
    WHEN 'HAPUS'.
      IF ld_count = 0.
        MESSAGE i000(zab)
             WITH 'Please select record with red light only'.
        EXIT.
      ENDIF.
      IF ld_count1 >= 1.
        MESSAGE i000(zab)
                WITH 'Only Record with Red light can be deleted'.
        EXIT.
      ENDIF.
      PERFORM f_delete.
      fu_selfield-refresh = 'X'.
    WHEN 'TAMBAH'.
*      CALL SCREEN '9000' STARTING AT 10 10  ENDING AT 55 12.
      CALL SELECTION-SCREEN 9009 STARTING AT 10 5 ENDING AT 100 10.
      CLEAR d_flg.

*      IF d_oke = 'Y'.
      IF sy-subrc = 0.
        PERFORM f_sap_data.
        fu_selfield-refresh = 'X'.
        IF d_flg IS INITIAL.
          MESSAGE i000(zab) WITH 'Document does not exist'.
        ENDIF.
      ENDIF.

    WHEN '&IC1'.
      CASE fu_selfield-sel_tab_field.
        WHEN '1-BELNR'.
          READ TABLE t_itab INDEX fu_selfield-tabindex.
          SET PARAMETER ID 'BLN' FIELD fu_selfield-value.
          SET PARAMETER ID 'BUK' FIELD p_bukrs.
          SET PARAMETER ID 'GJR' FIELD t_itab-budat(4).
          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDCASE.
  ENDCASE.

ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_CEK_FLAG_BFRSAVE
*&---------------------------------------------------------------------*
FORM f_cek_flag_bfrsave.

  CLEAR : d_wrongflag.

  LOOP AT t_itab WHERE cek = 'X'.

    IF t_itab-fakdat(4) GT 2006.
      REPLACE '-' WITH space INTO t_itab-fakturno_new.
      DO 2 TIMES.
        REPLACE '.' WITH space INTO t_itab-fakturno_new.
      ENDDO.
      CONDENSE t_itab-fakturno_new NO-GAPS.
      t_itab-fakturno = t_itab-fakturno_new.
    ELSE.
      t_itab-fakturno = t_itab-fakturno_new.
    ENDIF.

    CASE t_itab-credit.
      WHEN 'B' OR 'b'.
        IF t_itab-indicator = 1.
          t_itab-flag_data = '3'.
        ELSE.
          t_itab-flag_data = '1'.
        ENDIF.
        t_itab-form = ''.
        MODIFY t_itab INDEX sy-tabix TRANSPORTING flag_data
                                                  form
                                                  fakturno.
      WHEN 'C' OR 'c' OR 'D' OR 'd' OR 'I' OR 'i' OR 'X' OR 'x'.
        IF t_itab-indicator = 1.
          t_itab-flag_data = '3'.
        ELSE.
          t_itab-flag_data = '1'.
        ENDIF.
* Tidak bisa ke negatif value
        IF t_itab-fakppn < 0.
          ADD 1 TO d_wrongflag.
          t_itab-flag_data = '2'.
        ELSE.
          IF t_itab-credit = 'C' OR t_itab-credit = 'I' OR
             t_itab-credit = 'c' OR t_itab-credit = 'i'.
            t_itab-form = 'B1'.
          ENDIF.
          IF t_itab-credit = 'X' OR t_itab-credit = 'x'.
            t_itab-form = 'B2'.
          ENDIF.
          IF t_itab-credit = 'D' OR t_itab-credit = 'd'.
            IF p_bukrs EQ '8050'.
              t_itab-form = 'B3'.
            ELSE.
              t_itab-form = 'B4'.
            ENDIF.
          ENDIF.
        ENDIF.
        MODIFY t_itab INDEX sy-tabix TRANSPORTING flag_data
                                                  form
                                                  fakturno.
      WHEN 'R' OR 'r'.
        IF t_itab-indicator = 1.
          t_itab-flag_data = '3'.
        ELSE.
          t_itab-flag_data = '1'.
        ENDIF.
* Tidak bisa ke positif value
        IF t_itab-fakppn > 0.
          ADD 1 TO d_wrongflag.
          t_itab-flag_data = '2'.
        ELSE.
          t_itab-form = 'B1'.
        ENDIF.
        MODIFY t_itab INDEX sy-tabix TRANSPORTING flag_data
                                                  form
                                                  fakturno.
      WHEN OTHERS.
        ADD 1 TO d_wrongflag.
        t_itab-flag_data = '2'.
        MODIFY t_itab INDEX sy-tabix TRANSPORTING flag_data
                                                  fakturno.
    ENDCASE.

  ENDLOOP.

ENDFORM.                    " F_CEK_FLAG_BFRSAVE

*&---------------------------------------------------------------------*
*&      Form  F_TO_TXdt0012
*&---------------------------------------------------------------------*
FORM f_to_txdt0012.
  DATA: BEGIN OF lt_update OCCURS 0.
          INCLUDE STRUCTURE zgdtxdt0012.
          DATA:   fakturno_old      LIKE zgdtxdt0012-fakturno,
          fakdat_old        LIKE zgdtxdt0012-fakdat,
          fakturno_new1(19).
  DATA: END OF lt_update.

  DATA: BEGIN OF lt_insert OCCURS 0.
          INCLUDE STRUCTURE zgdtxdt0012.
        DATA: END OF lt_insert.

  DATA: BEGIN OF lt_tax12 OCCURS 0.
          INCLUDE STRUCTURE zgdtxdt0012.
        DATA: END OF lt_tax12.


  DATA : ld_answer(1)   TYPE c,
         ld_update      TYPE i,
         ld_insert      TYPE i,
         ld_tabix       TYPE i,
         ld_wrong(4)    TYPE c,
         ld_pesan(100)  TYPE c,
         ld_pesan1(100) TYPE c.

  REFRESH : lt_update, lt_insert, lt_tax12.
  CLEAR   : d_samefaktur, ld_pesan, ld_pesan1,
            ld_update, ld_insert, ld_tabix.

* Untuk pengecekan Faktur No.
  SELECT *
     INTO TABLE lt_tax12
     FROM zgdtxdt0012
  FOR ALL ENTRIES IN t_itab
  WHERE bukrs    = t_itab-bukrs AND
        fakturno = t_itab-fakturno AND
        lifnr    = t_itab-lifnr.

  SORT lt_tax12 BY fakturno.

*pake qty supaya digit di belakang koma hilang
  LOOP AT t_itab WHERE cek = 'X'.
    t_itab-itqty = t_itab-qty.
    MODIFY t_itab.
  ENDLOOP.


  CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
    EXPORTING
      defaultoption = 'Y'
      textline1     = 'Continue To Save'
*     TEXTLINE2     = ' '
      titel         = 'Update / Insert VAT-In data'
*     START_COLUMN  = 25
*     START_ROW     = 6
    IMPORTING
      answer        = ld_answer.

  IF ld_answer = 'J'.
****Update data
    IF NOT t_itab1[] IS INITIAL.
      SORT t_itab  BY bukrs brnch busln belnr budat buzei gjahr
                        fakturno_old fakdat_old masatx credit.
      SORT t_itab1 BY bukrs brnch busln belnr budat buzei gjahr
                        fakturno_old fakdat_old masatx credit.
    ENDIF.

    BREAK bcrmd.

    LOOP AT t_itab WHERE indicator = 0     AND
                         fakturno NE space AND
                         fakdat NE space   AND
                         flag_data NE 2    AND
                         cek = 'X'.
      ADD 1 TO ld_tabix.
      READ TABLE t_itab1 FROM t_itab.
      IF sy-subrc NE 0.
        IF t_itab-fakturno_old EQ t_itab-fakturno.
          MOVE-CORRESPONDING t_itab TO lt_update.
          APPEND lt_update.
          CLEAR lt_update.
        ELSE.
***changed for Tempo
*---------Check document type when saving data with the same Faktur no
*---------If credit = 'R', document with the same fakturno & type 'C'
*---------must have existed
          IF t_itab-credit = 'R'.
****This Checking logic is not applicable in Tempo since there are
****possibilities to return document with no reference (legacy data)
*            READ TABLE lt_tax12 WITH KEY fakturno = t_itab-fakturno
*                                         credit   = 'C'.
*            IF sy-subrc = 0.
            MOVE-CORRESPONDING t_itab TO lt_update.
            APPEND lt_update.
            CLEAR lt_update.
*            ELSE.
*              ADD 1 TO d_wrongflag.
*              t_itab-flag_data = '2'.
*              MODIFY t_itab INDEX ld_tabix TRANSPORTING flag_data.
*            ENDIF.
****end of logic removal
          ELSE.
*---------If credit = others, document with the same fakturno must NOT
*---------have existed
            READ TABLE lt_tax12 WITH KEY bukrs    = t_itab-bukrs
                                         fakturno = t_itab-fakturno
                                         lifnr    = t_itab-lifnr
                                BINARY SEARCH.
            IF sy-subrc = 0.
              ADD 1 TO d_samefaktur.
              t_itab-flag_data = '2'.
              MODIFY t_itab INDEX ld_tabix TRANSPORTING flag_data.
            ELSE.
              MOVE-CORRESPONDING t_itab TO lt_update.
              APPEND lt_update.
              CLEAR lt_update.
            ENDIF.
          ENDIF.
***end of Tempo changes
        ENDIF.

      ELSE.                  "If Only Qty Change
        IF t_itab-itqty NE t_itab1-itqty.
          MOVE-CORRESPONDING t_itab TO lt_update.
          APPEND lt_update.
          CLEAR lt_update.
        ENDIF.
      ENDIF.
      CLEAR t_itab.
    ENDLOOP.

****Insert data
    CLEAR ld_tabix.
    LOOP AT t_itab WHERE indicator = 1     AND
                         fakturno NE space AND
                         fakdat NE space   AND
                         flag_data NE 2    AND
                         cek = 'X'.
      ADD 1 TO ld_tabix.

***changed for Tempo
*---------Check document type when saving data with the same Faktur no
*---------If credit = 'R', document with the same fakturno & type 'C'
*---------must have existed
      IF t_itab-credit = 'R'.
        READ TABLE lt_tax12 WITH KEY bukrs    = t_itab-bukrs
                                     fakturno = t_itab-fakturno
                                     lifnr    = t_itab-lifnr
                                     credit   = 'C'.
        IF sy-subrc = 0.
          ADD 1 TO ld_insert.
          MOVE-CORRESPONDING t_itab TO lt_insert.
          APPEND lt_insert.
          CLEAR lt_insert.
        ELSE.
****apply this logic only after SEPT 2005 (1 month after golive)
****requested by Steve for Tempo
****consider correct until end of SEPT 2005
*          IF sy-datum > '20050930'.
*            ADD 1 TO d_wrongflag.
*            t_itab-flag_data = '2'.
*            MODIFY t_itab INDEX ld_tabix TRANSPORTING flag_data.
*          ELSE.
          ADD 1 TO ld_insert.
          MOVE-CORRESPONDING t_itab TO lt_insert.
          APPEND lt_insert.
          CLEAR lt_insert.
*          ENDIF.
****end of logic for after SEPT 2005
        ENDIF.
      ELSE.
*---------If credit = others, document with the same fakturno must NOT
*---------have existed
        READ TABLE lt_tax12 WITH KEY bukrs    = t_itab-bukrs
                                     fakturno = t_itab-fakturno
                                     lifnr    = t_itab-lifnr
                            BINARY SEARCH.
        IF sy-subrc = 0.
          ADD 1 TO d_samefaktur.
          t_itab-flag_data = '2'.
          MODIFY t_itab INDEX ld_tabix TRANSPORTING flag_data.
        ELSE.
          ADD 1 TO ld_insert.
          MOVE-CORRESPONDING t_itab TO lt_insert.
          APPEND lt_insert.
          CLEAR lt_insert.
        ENDIF.
      ENDIF.

*      READ TABLE lt_tax12 WITH KEY fakturno = t_itab-fakturno
*                 BINARY SEARCH.
*      IF sy-subrc = 0.
*        ADD 1 TO d_samefaktur.
*        t_itab-flag_data = '2'.
*        MODIFY t_itab INDEX ld_tabix TRANSPORTING flag_data.
*      ELSE.
*        ADD 1 TO ld_insert.
*        MOVE-CORRESPONDING t_itab TO lt_insert.
*        APPEND lt_insert.
*        CLEAR lt_insert.
*      ENDIF.
***end of Tempo changes
    ENDLOOP.


*  delete from ZGDTXdt0012 where userid = 'ABAP-TSA'.
    IF NOT lt_update[] IS INITIAL.
      LOOP AT lt_update.
        ADD 1 TO ld_update.

        REPLACE '-' WITH space INTO lt_update-fakturno_new1.
        DO 2 TIMES.
          REPLACE '.' WITH space INTO lt_update-fakturno_new1.
        ENDDO.
        CONDENSE lt_update-fakturno_new1 NO-GAPS.

        UPDATE zgdtxdt0012
          SET fakturno = lt_update-fakturno
              fakdat   = lt_update-fakdat
              name     = lt_update-name
              npwp     = lt_update-npwp
              itqty    = lt_update-itqty
              item     = lt_update-item
              credit   = lt_update-credit
              form     = lt_update-form
              fakturno_new  = lt_update-fakturno_new1
        WHERE bukrs    = lt_update-bukrs
        AND   brnch    = lt_update-brnch
        AND   busln    = lt_update-busln
        AND   belnr    = lt_update-belnr
        AND   budat    = lt_update-budat
        AND   buzei    = lt_update-buzei
        AND   gjahr    = lt_update-gjahr
        AND   fakturno = lt_update-fakturno_old
        AND   fakdat   = lt_update-fakdat_old
        AND   masatx   = lt_update-masatx.

      ENDLOOP.
*    UPDATE ZGDTXdt0012 FROM TABLE lt_update.
    ENDIF.

    IF NOT lt_insert[] IS INITIAL.
      INSERT zgdtxdt0012 FROM TABLE lt_insert.
      IF p_bukrs = '8360'.
        "KMM3 Project
        READ TABLE lt_insert INDEX 1.
        CALL FUNCTION 'ZKMMFI_UPDATE_XREF2'
          EXPORTING
            pi_bukrs = lt_insert-bukrs
            pi_belnr = lt_insert-belnr
            pi_gjahr = lt_insert-gjahr
            pi_hkont = '0142200100'
            pi_xref2 = 'PPN_IN'.

        CALL FUNCTION 'ZKMMFI_UPDATE_XREF2'
          EXPORTING
            pi_bukrs = lt_insert-bukrs
            pi_belnr = lt_insert-belnr
            pi_gjahr = lt_insert-gjahr
            pi_hkont = '0142200220'
            pi_xref2 = 'PPN_IN'.
      ENDIF.
    ENDIF.

    COMMIT WORK.
    IF sy-subrc EQ 0.
      CLEAR : ld_wrong.
      t_itab-flag_data = '1'.
      t_itab-indicator = 0.

      MODIFY t_itab TRANSPORTING flag_data indicator
                 WHERE
                    flag_data NE '2'  AND
                    fakturno NE space AND
                    fakdat NE space AND
                    cek = 'X'.

      ld_wrong = ld_update.
      CONCATENATE ld_wrong 'record(s) updated,' INTO ld_pesan
                  SEPARATED BY space.
      CLEAR ld_wrong.
      ld_wrong = d_wrongflag.
      CONCATENATE ld_pesan ld_wrong 'record(s) with errors,'
                  INTO ld_pesan
                  SEPARATED BY space.

      CLEAR ld_wrong.
      ld_wrong = d_samefaktur.
      CONCATENATE ld_wrong 'record(s) with same faktur no'
                  INTO ld_pesan1
                  SEPARATED BY space.

      MESSAGE i000(zab) WITH ld_insert ' record(s) inserted, '
                       ld_pesan ld_pesan1.

      REFRESH : t_itab1.
      LOOP AT t_itab WHERE flag_data NE '2' AND cek = 'X'.
        t_itab-fakturno_old = t_itab-fakturno.
        t_itab-fakdat_old   = t_itab-fakdat.
        t_itab-qty          = t_itab-itqty.
        MODIFY t_itab.
      ENDLOOP.

      t_itab1[] = t_itab[].
    ENDIF.
  ENDIF.
ENDFORM.                    " F_TO_TXdt0012

*&---------------------------------------------------------------------*
*&      Form  F_DELETE
*&---------------------------------------------------------------------*
FORM f_delete.
  DATA: BEGIN OF lt_delete OCCURS 0.
          INCLUDE STRUCTURE zgdtxdt0012.
        DATA: END OF lt_delete.

  DATA : ld_answer(1) TYPE c.

  REFRESH : lt_delete.

  CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
    EXPORTING
      defaultoption = 'Y'
      textline1     = 'Continue To Delete'
*     TEXTLINE2     = ' '
      titel         = 'Delete Existing VAT-In data'
*     START_COLUMN  = 25
*     START_ROW     = 6
    IMPORTING
      answer        = ld_answer.

  IF ld_answer = 'J'.
****Delete data
    LOOP AT t_itab WHERE cek = 'X' AND flag_data = '1'.
      IF t_itab-files IS INITIAL.
        MOVE-CORRESPONDING t_itab TO lt_delete.
        APPEND lt_delete.
        CLEAR lt_delete.
      ELSE.
        MESSAGE i000(zab)
                WITH 'Data sudah diproses eFaktur' t_itab-files.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF NOT lt_delete[] IS INITIAL.
      DELETE zgdtxdt0012 FROM TABLE lt_delete.
    ENDIF.

    COMMIT WORK.
    IF sy-subrc EQ 0.
      DELETE t_itab WHERE cek = 'X'
                      AND flag_data = '1'
                      AND files IS INITIAL.
      MESSAGE s000(zab) WITH 'Data has been deleted'.

      REFRESH : t_itab1.
      LOOP AT t_itab WHERE flag_data NE '2' AND cek = 'X'.
        t_itab-fakturno_old = t_itab-fakturno.
        t_itab-fakdat_old   = t_itab-fakdat.
        t_itab-qty          = t_itab-itqty.
        MODIFY t_itab.
      ENDLOOP.

      t_itab1[] = t_itab[].

    ENDIF.
  ENDIF.

ENDFORM.                    " F_DELETE

*&---------------------------------------------------------------------*
*&      Form  F_SCREEN_OKE
*&---------------------------------------------------------------------*
FORM f_screen_oke.
  d_error = 0.
  d_oke = 'Y'.

*  IF d_belnrfrom EQ space.
  IF s_beln-low EQ space.
    MESSAGE s000(zab) WITH
      'Please fill Document No.'.
    d_error = 4.
    d_oke = 'N'.
    EXIT.
  ENDIF.

*  IF d_belnrto NE space.
*    IF d_belnrto < d_belnrfrom.
  IF s_beln-high NE space.
    IF s_beln-high < s_beln-low.
      MESSAGE s000(zab) WITH
        'Invalid Document No. Range'.
      d_error = 4.
      d_oke = 'N'.
      EXIT.
    ENDIF.
  ENDIF.

*  IF d_gjahr EQ space.    "fikk 21/06/2004 GJHR-->GJHR2
  IF d_gjahr2 EQ space.    "fikk 21/06/2004 GJHR-->GJHR2
    MESSAGE s000(zab) WITH
      'Please fill Fiscal Year'.
    d_error = 4.
    d_oke = 'N'.
    EXIT.
  ENDIF.

ENDFORM.                    " F_SCREEN_OKE

*&---------------------------------------------------------------------*
*&      Form  f_check_branch
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BRNCH  text
*----------------------------------------------------------------------*
FORM f_check_branch USING    fu_bukrs
                             fu_brnch.

  SELECT SINGLE * FROM zgdtxdt0101
                  WHERE brnch = fu_brnch AND
                        bukrs = fu_bukrs.

  IF sy-subrc <> 0.
    MESSAGE e000(zab) WITH 'The branch is not defined'.
  ENDIF.

ENDFORM.                    " f_check_branch

*&---------------------------------------------------------------------*
*&      Form  f_select_branch
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->fT_BSEG  text
*      -->fu_BUKRS  text
*      -->fu_BRNCH  text
*----------------------------------------------------------------------*
FORM f_select_branch TABLES   ft_bseg STRUCTURE zgdtxst0008
                     USING    fu_bukrs
                              fu_brnch.

***Put Company specific logic to determine branch
***in below User Exit
  LOOP AT ft_bseg.
    CALL FUNCTION 'Z_GDTXFC_EXIT_ACCT_BRNCH_DETM'
      EXPORTING
        fi_bukrs                 = fu_bukrs
        fi_brnch                 = fu_brnch
        fi_bseg                  = ft_bseg
      IMPORTING
        fe_bseg                  = ft_bseg
      TABLES
        ft_tx00101               = t_tx00101
      EXCEPTIONS
        branch_is_not_maintained = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0.
      MESSAGE e000(zab) WITH 'Branch is not maintained'.
    ENDIF.
    MODIFY ft_bseg.
  ENDLOOP.

* Based on selection parameter delete those which are not
* relevant to be processed.
  DELETE ft_bseg WHERE brnch <> fu_brnch OR
                       bukrs <> fu_bukrs.

ENDFORM.                    " f_select_branch

*&---------------------------------------------------------------------*
*&      Form  f_check_tax_period
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_tax_period CHANGING fc_subrc LIKE sy-subrc.

  DATA ld_status.
  DATA ld_uname LIKE sy-uname.
  DATA: tx04usr LIKE indx-srtfd VALUE 'ZGDTXDT0106'.

  CALL FUNCTION 'Z_GDTXFC_CHECK_TAX_PERIOD'
    IMPORTING
      fe_status                    = ld_status
      fe_uname                     = ld_uname
    EXCEPTIONS
      program_running              = 1
      tax_period_program_not_found = 2
      OTHERS                       = 3.
  fc_subrc = sy-subrc.
  IF fc_subrc <> 0.
    CASE fc_subrc.
      WHEN 1.
        IMPORT zgdtxdt0106-uname FROM MEMORY ID tx04usr.
        ld_uname = zgdtxdt0106-uname.
        MESSAGE i000(zab) WITH 'Tax period program is still locked by'
                               ld_uname.
      WHEN 2.
        MESSAGE i000(zab) WITH 'Please maintain Tax period program to'
                               'ZGDTXDT0106 table'.
    ENDCASE.
    EXIT.
  ENDIF.

ENDFORM.                    " f_check_tax_period

*&---------------------------------------------------------------------*
*&      Form  f_calc_dpp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_DMBTR  text
*      <--FC_ITAMT  text
*----------------------------------------------------------------------*
FORM f_calc_dpp USING    fu_bseg LIKE t_bseg
                CHANGING fc_itamt.

  DATA ld_knumh LIKE konp-knumh.
  DATA ld_kbetr LIKE konp-kbetr.
  DATA ld_tax LIKE konp-kbetr.

  READ TABLE t_tx00101 WITH KEY brnch = p_brnch.

*-Get INDONESIAN INPUT TAX
  IF fu_bseg-waers <> 'IDR'.  "bugfix by Rahmadi (Tempo)
    SELECT SINGLE knumh INTO ld_knumh
                        FROM a003
                        WHERE kappl = 'TX' AND
                              kschl = 'MWVS' AND
                              aland = 'ID' AND
                              mwskz = t_tx00101-vitxcode_f.
  ELSE.
    SELECT SINGLE knumh INTO ld_knumh
                        FROM a003
                        WHERE kappl = 'TX' AND
                              kschl = 'MWVS' AND
                              aland = 'ID' AND
                              mwskz = t_tx00101-vitxcode.
  ENDIF.

  IF sy-subrc = 0.
    SELECT SINGLE kbetr INTO ld_kbetr
                        FROM konp
                        WHERE knumh = ld_knumh.
    ld_tax = ld_kbetr / 10.
********** Modified by Budi (15-09-2005)
********** intruksi by Rahmadi Req. By Tavid
*    fc_itamt = fu_bseg-dmbtr * ld_tax.
*    fc_itamt = fu_bseg-dmbtr / ( 1 + ( ld_tax / 100 ) ).
***** New formula by Trias
*    IF fu_bseg-shkzg EQ 'H'.
*      fu_bseg-dmbtr = fu_bseg-dmbtr * -1.
*    ENDIF.

* 05 OKT 2006
    IF fu_bseg-hwbas EQ 0.
      IF fu_bseg-shkzg EQ 'H'.
        fc_itamt = ( fu_bseg-dmbtr / ( ld_tax / 100 ) ) * -1.
      ELSE.
        fc_itamt = fu_bseg-dmbtr / ( ld_tax / 100 ).
      ENDIF.
    ELSE.
      IF fu_bseg-shkzg EQ 'H'.
        fc_itamt = fu_bseg-hwbas * -1.
      ELSE.
        fc_itamt = fu_bseg-hwbas.
      ENDIF.
    ENDIF.
********** End of Modified by Budi (15-09-2005)
  ELSE.
    MESSAGE i000(zab) WITH 'Document' fu_bseg-belnr
                           fu_bseg-buzei
                           'is not tax relevant'.
  ENDIF.

ENDFORM.                    " f_calc_dpp

*&---------------------------------------------------------------------*
*&      Form  F_CALC_DPP8050
*&---------------------------------------------------------------------*
FORM f_calc_dpp8050  USING    fu_bseg LIKE t_bseg
                     CHANGING fc_itamt fc_fakppn.

  DATA ld_knumh LIKE konp-knumh.
  DATA ld_kbetr LIKE konp-kbetr.
  DATA ld_tax LIKE konp-kbetr.
  DATA: ld_kschl  LIKE konp-kschl,
        ld_actype LIKE zgdtxdt0015-actype.

* GL account 08* KSCHL = MWVZ else MWVS
  SELECT SINGLE actype
    FROM zgdtxdt0015
    INTO ld_actype
    WHERE hkontfr LE fu_bseg-hkont AND
          hkontto GE fu_bseg-hkont.
  IF sy-subrc EQ 0.
    IF ld_actype EQ 'L'.
      ld_kschl  = 'MWVZ'.
    ELSEIF ld_actype EQ 'I'.
      ld_kschl  = 'MWVS'.
    ENDIF.
  ENDIF.

  SELECT SINGLE knumh INTO ld_knumh
                      FROM a003
                      WHERE kappl = 'TX' AND
                            kschl = ld_kschl AND
                            aland = 'ID' AND
                            mwskz = fu_bseg-mwskz.
  IF sy-subrc = 0.
    SELECT SINGLE kbetr INTO ld_kbetr
                        FROM konp
                        WHERE knumh = ld_knumh.
    ld_tax = ld_kbetr / 10.
  ENDIF.
  READ TABLE t_bset WITH KEY bukrs  = fu_bseg-bukrs
                             belnr  = fu_bseg-belnr
                             gjahr  = fu_bseg-gjahr.
  IF sy-subrc EQ 0.
    IF t_bset-shkzg EQ 'H'.
      fc_itamt  = t_bset-fwbas * -1.
      fc_fakppn = t_bset-fwste * -1.
    ELSE.
      fc_itamt  = t_bset-fwbas.
      fc_fakppn = t_bset-fwste.
    ENDIF.
    IF fc_fakppn IS INITIAL.
      fc_fakppn = fc_itamt.
      fc_itamt  = fc_fakppn / ( ld_tax / 100 ).
    ENDIF.
  ELSE.
    IF fu_bseg-shkzg EQ 'H'.
      fc_itamt = ( fu_bseg-dmbtr / ( ld_tax / 100 ) ) * -1.
    ELSE.
      fc_itamt = fu_bseg-dmbtr / ( ld_tax / 100 ).
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CALC_DPP8050

*&---------------------------------------------------------------------*
*&      Form  F_GET_CREDIT
*&---------------------------------------------------------------------*
FORM f_get_credit  CHANGING fc_credit.
  RANGES: lr_mwskz FOR bseg-mwskz.
  lr_mwskz-low      = 'B5'.
  lr_mwskz-sign     = 'I'.
  lr_mwskz-option   = 'EQ'.
  APPEND lr_mwskz.
  lr_mwskz-low      = 'B6'.
  lr_mwskz-sign     = 'I'.
  lr_mwskz-option   = 'EQ'.

  APPEND lr_mwskz.
  IF t_bkpf-stblg NE space.
    fc_credit = 'B'.
  ELSE.
    IF t_bseg-mwskz IN lr_mwskz.
      IF t_bseg-shkzg = 'S'.
        fc_credit = 'D'.
      ENDIF.
      IF t_bseg-shkzg = 'H'.
        fc_credit = 'B'.
      ENDIF.
    ELSE.
      IF t_bseg-shkzg = 'S'.
        fc_credit = 'C'.
      ENDIF.
      IF t_bseg-shkzg = 'H'.
        fc_credit = 'R'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_CREDIT

*&---------------------------------------------------------------------*
*&      Form  F_TAX_CALC
*&---------------------------------------------------------------------*
FORM f_tax_calc  USING    fu_datum fu_mastx fu_wrbtr fu_calty
                 CHANGING fc_wrbtr.
  DATA : lv_wrbtr TYPE netwr_ak,
         lv_datum TYPE sy-datum.

  lv_wrbtr    = fu_wrbtr.
  lv_datum    = fu_datum.

  CALL FUNCTION 'Z_PPN11'
    EXPORTING
      pi_wrbtr = lv_wrbtr
      pi_calty = fu_calty
      pi_datum = lv_datum
      pi_mastx = fu_mastx
    IMPORTING
      po_wrbtr = lv_wrbtr.

  fc_wrbtr  = lv_wrbtr.
ENDFORM.                    " F_TAX_CdfALC
