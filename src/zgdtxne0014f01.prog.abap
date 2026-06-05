*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNE0014F01                                           *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_JOIN_FKART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_join_fkart.

  APPEND LINES OF r_fkartn TO r_fkart.
  APPEND LINES OF r_fkartr TO r_fkart.
  APPEND LINES OF r_fkartp TO r_fkart.
  APPEND LINES OF r_fkartx TO r_fkart.
  APPEND LINES OF r_fkartc TO r_fkart.

ENDFORM.                    " F_JOIN_FKART

*&---------------------------------------------------------------------*
*&      Form  F_GET_BILL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_VBRK0  text
*----------------------------------------------------------------------*
FORM f_get_bill TABLES ft_vbrk0 STRUCTURE t_vbrk0.

  DATA lt_vbfaca LIKE vbfa OCCURS 1 WITH HEADER LINE.
  DATA lt_vbfacr LIKE vbfa OCCURS 1 WITH HEADER LINE.
  DATA lt_vbfacc LIKE vbfa OCCURS 1 WITH HEADER LINE.
  DATA lt_vbfa1 LIKE vbfa OCCURS 1 WITH HEADER LINE.
  DATA ld_vbco6 LIKE vbco6.
  DATA lt_vbfa2 LIKE vbfa OCCURS 1 WITH HEADER LINE.
  DATA ld_vbco5 LIKE vbco6.

  DATA ld_user LIKE sy-msgv1.
  DATA ld_subrc LIKE sy-subrc.
  DATA lw_vbrk LIKE t_vbrk.
  DATA ld_tabix LIKE sy-tabix.

  CLEAR: t_noref, t_noref[].

*** Get VBFA Tables
  SELECT vbelv posnv vbeln posnn vbtyp_n vbtyp_v
         INTO CORRESPONDING FIELDS OF TABLE t_vbfa
         FROM vbfa
         FOR ALL ENTRIES IN ft_vbrk0
         WHERE vbeln = ft_vbrk0-vbeln AND
               posnn = ft_vbrk0-posnr.

*   to handle cancellation billing that delivery note had been
*   deleted, so link in document order flow will be gone
  DATA: BEGIN OF lt_vbrk_vbeln OCCURS 0,
          vbeln LIKE vbrk-vbeln,
        END OF lt_vbrk_vbeln.

  LOOP AT ft_vbrk0 WHERE fkart IN r_fkartc.
    lt_vbrk_vbeln-vbeln = ft_vbrk0-sfakn.
    APPEND lt_vbrk_vbeln.
  ENDLOOP.

  DATA: lt_vbrk_vbelv LIKE lt_vbrk_vbeln OCCURS 0 WITH HEADER LINE.
***bugfix at Tempo --- select all entries only if having value
  IF NOT lt_vbrk_vbeln[] IS INITIAL.
    SELECT vbeln
           FROM  vbrk
           INTO  TABLE lt_vbrk_vbelv
           FOR   ALL ENTRIES IN lt_vbrk_vbeln
           WHERE vbrk~vbeln = lt_vbrk_vbeln-vbeln.
    SORT lt_vbrk_vbelv BY vbeln.
  ENDIF.
***end of bugfix
  LOOP AT ft_vbrk0 WHERE fkart IN r_fkartc.
    READ TABLE lt_vbrk_vbelv WITH KEY vbeln = ft_vbrk0-sfakn.
    CHECK sy-subrc = 0.
    READ TABLE t_vbfa WITH KEY vbeln = lt_vbrk_vbelv-vbeln.
    CHECK sy-subrc <> 0.
    t_vbfa-vbelv = lt_vbrk_vbelv-vbeln.
    t_vbfa-vbtyp_v = 'M'.  "Invoice
    t_vbfa-vbeln = ft_vbrk0-vbeln.
    t_vbfa-vbtyp_n = 'N'.  "Invoice Cancellation.
    APPEND t_vbfa.
  ENDLOOP.

  LOOP AT ft_vbrk0.
    ld_tabix = sy-tabix.

*--- Check Billing Exist in Table 00002
    CLEAR: zgdtxdt0002-vbeln.
    SELECT SINGLE vbeln
         INTO zgdtxdt0002-vbeln
         FROM zgdtxdt0002
         WHERE vbeln = ft_vbrk0-vbeln.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ft_vbrk0 TO t_error.
      t_error-msg = 'Billing has been processed'.
      APPEND t_error.
      DELETE ft_vbrk0.
      CONTINUE.
    ENDIF.

*---Checking Normal billing for Credit memo
    SORT t_vbfa BY vbeln posnv.
    READ TABLE t_vbfa WITH KEY vbeln   = ft_vbrk0-vbeln
                               vbtyp_n = 'O'  "O=Credit Memo
                               vbtyp_v = 'M'  "M=Invoice
                               flag    = space.
    IF sy-subrc = 0.
      t_vbfa-flag = 'X'.
      MODIFY t_vbfa INDEX sy-tabix TRANSPORTING flag.
      ft_vbrk0-vbelv = t_vbfa-vbelv.
      ft_vbrk0-posnv = t_vbfa-posnv.

      MOVE-CORRESPONDING ft_vbrk0 TO lw_vbrk.
      PERFORM f_process_locked_norm_billings USING lw_vbrk
                                                   ld_user
                                                   ld_subrc.

      CLEAR: zgdtxdt0002-vbeln.
      SELECT SINGLE vbeln fakturno
             INTO (zgdtxdt0002-vbeln, zgdtxdt0002-fakturno)
             FROM zgdtxdt0002
             WHERE vbeln = ft_vbrk0-vbelv.
      IF sy-subrc <> 0.
        MOVE-CORRESPONDING ft_vbrk0 TO t_error.
        t_error-msg = 'Billing Normal has not been processed'.
        APPEND t_error.
        DELETE ft_vbrk0.
        CONTINUE.
      ELSE.
        ft_vbrk0-fakturno = zgdtxdt0002-fakturno.
        CLEAR: zgdtxdt0003-faktur_type.
        SELECT SINGLE fakdat faktur_type
         INTO (zgdtxdt0003-fakdat, zgdtxdt0003-faktur_type)
         FROM zgdtxdt0003
         WHERE fakturno = zgdtxdt0002-fakturno.
        IF sy-subrc = 0.
          ft_vbrk0-faktur_type = zgdtxdt0003-faktur_type.
        ENDIF.

        REFRESH: lt_vbfa1.
        CLEAR: lt_vbfa1.
        CLEAR: ld_vbco6.
        ld_vbco6-vbeln = ft_vbrk0-vbeln.
        ld_vbco6-posnr = ft_vbrk0-posnr.

        CALL FUNCTION 'RV_ORDER_FLOW_INFORMATION'
          EXPORTING
            comwa         = ld_vbco6
          TABLES
            vbfa_tab      = lt_vbfa1
          EXCEPTIONS
            no_vbfa       = 1
            no_vbuk_found = 2
            OTHERS        = 3.
        IF sy-subrc = 0.

          IF ( ft_vbrk0-fkart IN r_fkartr )
             OR ( ft_vbrk0-fkart IN r_fkartp ).
            lt_vbfacr[] = lt_vbfa1[].
            DELETE lt_vbfacr WHERE NOT vbtyp_n = 'S'.
            APPEND LINES OF lt_vbfacr TO t_vbfacr.
          ENDIF.

          IF ft_vbrk0-fkart IN r_fkartc.
            lt_vbfacc[] = lt_vbfa1[].
            DELETE lt_vbfacc WHERE NOT vbtyp_n = '+'.
            APPEND LINES OF lt_vbfacc TO t_vbfacc.
          ENDIF.

          READ TABLE lt_vbfa1 WITH KEY vbelv   = ft_vbrk0-vbeln
                                       vbtyp_n = '+'.
          IF sy-subrc = 0.
            ft_vbrk0-belnr = lt_vbfa1-vbeln.
          ENDIF.
        ENDIF.
        MODIFY ft_vbrk0 INDEX ld_tabix.
      ENDIF.
***added by Rahmadi for Debit memo 16/07/2004
*---Checking Normal billing for Debit memo
    ELSE.
      READ TABLE t_vbfa WITH KEY vbeln   = ft_vbrk0-vbeln
                                 vbtyp_n = 'P'  "P=Debit Memo
                                 vbtyp_v = 'M'  "M=Invoice
                                 flag    = space.
      IF sy-subrc = 0.
        t_vbfa-flag = 'X'.
        MODIFY t_vbfa INDEX sy-tabix TRANSPORTING flag.
        ft_vbrk0-vbelv = t_vbfa-vbelv.
        ft_vbrk0-posnv = t_vbfa-posnv.

        MOVE-CORRESPONDING ft_vbrk0 TO lw_vbrk.
        PERFORM f_process_locked_norm_billings USING lw_vbrk
                                                     ld_user
                                                     ld_subrc.

        CLEAR: zgdtxdt0002-vbeln.
        SELECT SINGLE vbeln fakturno
               INTO (zgdtxdt0002-vbeln, zgdtxdt0002-fakturno)
               FROM zgdtxdt0002
               WHERE vbeln = ft_vbrk0-vbelv.
        IF sy-subrc <> 0.
          MOVE-CORRESPONDING ft_vbrk0 TO t_error.
          t_error-msg = 'Billing Normal has not been processed'.
          APPEND t_error.
          DELETE ft_vbrk0.
          CONTINUE.
        ELSE.
          ft_vbrk0-fakturno = zgdtxdt0002-fakturno.
          CLEAR: zgdtxdt0003-faktur_type.
          SELECT SINGLE fakdat faktur_type
           INTO (zgdtxdt0003-fakdat, zgdtxdt0003-faktur_type)
           FROM zgdtxdt0003
           WHERE fakturno = zgdtxdt0002-fakturno.
          IF sy-subrc = 0.
            ft_vbrk0-faktur_type = zgdtxdt0003-faktur_type.
          ENDIF.

          REFRESH: lt_vbfa1.
          CLEAR: lt_vbfa1.
          CLEAR: ld_vbco6.
          ld_vbco6-vbeln = ft_vbrk0-vbeln.
          ld_vbco6-posnr = ft_vbrk0-posnr.

          CALL FUNCTION 'RV_ORDER_FLOW_INFORMATION'
            EXPORTING
              comwa         = ld_vbco6
            TABLES
              vbfa_tab      = lt_vbfa1
            EXCEPTIONS
              no_vbfa       = 1
              no_vbuk_found = 2
              OTHERS        = 3.
          IF sy-subrc = 0.

            IF ( ft_vbrk0-fkart IN r_fkartr )
               OR ( ft_vbrk0-fkart IN r_fkartp ).
              lt_vbfacr[] = lt_vbfa1[].
              DELETE lt_vbfacr WHERE NOT vbtyp_n = 'S'.
              APPEND LINES OF lt_vbfacr TO t_vbfacr.
            ENDIF.

            IF ft_vbrk0-fkart IN r_fkartc.
              lt_vbfacc[] = lt_vbfa1[].
              DELETE lt_vbfacc WHERE NOT vbtyp_n = '+'.
              APPEND LINES OF lt_vbfacc TO t_vbfacc.
            ENDIF.

            READ TABLE lt_vbfa1 WITH KEY vbelv   = ft_vbrk0-vbeln
                                         vbtyp_n = '+'.
            IF sy-subrc = 0.
              ft_vbrk0-belnr = lt_vbfa1-vbeln.
            ENDIF.
          ENDIF.
          MODIFY ft_vbrk0 INDEX ld_tabix.
        ENDIF.
      ENDIF.
***end of addition by Rahmadi 16/07/2004
    ENDIF.

  ENDLOOP.

  BREAK bcrmd.

  LOOP AT ft_vbrk0.
* add by Budi req by SJT 11/10/2005
    ld_tabix = sy-tabix.
* end add by Budi req by SJT 11/10/2005

*--- Check Billing Exist in Table 00002
    CLEAR: zgdtxdt0002-vbeln.
    SELECT SINGLE vbeln
         INTO zgdtxdt0002-vbeln
         FROM zgdtxdt0002
         WHERE vbeln = ft_vbrk0-vbeln.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ft_vbrk0 TO t_error.
      t_error-msg = 'Billing has been processed'.
      APPEND t_error.
      DELETE ft_vbrk0.
      CONTINUE.
    ENDIF.

*---Credit memo
    READ TABLE t_vbfa WITH KEY vbeln = ft_vbrk0-vbeln
                                  vbtyp_n = 'O'   "O = Credit Memo
                                  vbtyp_v = 'M'.  "M = Invoice
    IF sy-subrc <> 0.

***added by Rahmadi 16/07/2004 for Debit memo
*-----Debit memo
      READ TABLE t_vbfa WITH KEY vbeln = ft_vbrk0-vbeln
                                 vbtyp_n = 'P'   "P = Debit Memo
                                 vbtyp_v = 'M'.  "M = Invoice
      IF sy-subrc <> 0.
***end of addition 16/07/2004 for Debit memo
*INVESTIGATE LOGIC FOR NOREF
*break bcrmd.
        IF ft_vbrk0-fkart IN r_fkartc.
          REFRESH: lt_vbfa2.
          CLEAR: lt_vbfa2.
          CLEAR: ld_vbco6.

          ld_vbco5-vbeln = ft_vbrk0-vbeln.
          ld_vbco5-posnr = ft_vbrk0-posnr.

          CALL FUNCTION 'RV_ORDER_FLOW_INFORMATION'
            EXPORTING
              comwa         = ld_vbco5
            TABLES
              vbfa_tab      = lt_vbfa2
            EXCEPTIONS
              no_vbfa       = 1
              no_vbuk_found = 2
              OTHERS        = 3.
          IF sy-subrc = 0.

            lt_vbfaca[] = lt_vbfa2[].
            DELETE lt_vbfaca WHERE NOT vbtyp_n = 'N'.
            APPEND LINES OF lt_vbfaca TO t_vbfaca.

*           to handle cancellation billing that delivery note had been
*           deleted, so link in order flow will be gone
            READ TABLE t_vbfa WITH KEY vbeln   = ft_vbrk0-vbeln
                                       vbtyp_v = 'M'
                                       vbtyp_n = 'N'.
            IF sy-subrc = 0.
              READ TABLE t_vbfaca WITH KEY vbelv = t_vbfa-vbelv.
              IF sy-subrc <> 0.
                MOVE-CORRESPONDING t_vbfa TO t_vbfaca.
                APPEND t_vbfaca.
              ENDIF.
            ENDIF.
          ENDIF.

***added for Tempo to accomodate CREATE WITH NO REFERENCE
          IF lt_vbfaca[] IS INITIAL.
            MOVE-CORRESPONDING ft_vbrk0 TO t_noref.
            t_noref-vbelv = 'NOREF'.
            t_noref-posnv = 'NOREF'.
            APPEND t_noref.
          ENDIF.
***end of Tempo addition

        ELSE.
***added for Tempo to accomodate CREATE WITH NO REFERENCE
*****added to check accounting document - Tempo 28/06/2005
          REFRESH: lt_vbfa1.
          CLEAR: lt_vbfa1.
          CLEAR: ld_vbco6.
          ld_vbco6-vbeln = ft_vbrk0-vbeln.
          ld_vbco6-posnr = ft_vbrk0-posnr.

          CALL FUNCTION 'RV_ORDER_FLOW_INFORMATION'
            EXPORTING
              comwa         = ld_vbco6
            TABLES
              vbfa_tab      = lt_vbfa1
            EXCEPTIONS
              no_vbfa       = 1
              no_vbuk_found = 2
              OTHERS        = 3.
          IF sy-subrc = 0.

            IF ( ft_vbrk0-fkart IN r_fkartr )
               OR ( ft_vbrk0-fkart IN r_fkartp ).
              lt_vbfacr[] = lt_vbfa1[].
              DELETE lt_vbfacr WHERE NOT vbtyp_n = 'S'.
              APPEND LINES OF lt_vbfacr TO t_vbfacr.
            ENDIF.

            IF ft_vbrk0-fkart IN r_fkartc.
              lt_vbfacc[] = lt_vbfa1[].
              DELETE lt_vbfacc WHERE NOT vbtyp_n = '+'.
              APPEND LINES OF lt_vbfacc TO t_vbfacc.
            ENDIF.

            READ TABLE lt_vbfa1 WITH KEY vbelv   = ft_vbrk0-vbeln
                                         vbtyp_n = '+'.
            IF sy-subrc = 0.
              ft_vbrk0-belnr = lt_vbfa1-vbeln.
            ENDIF.
          ENDIF.
          MODIFY ft_vbrk0 INDEX ld_tabix.
****end of addition for NOREF accounting doc 28/06/2005

          MOVE-CORRESPONDING ft_vbrk0 TO t_noref.
          t_noref-vbelv = 'NOREF'.
          t_noref-posnv = 'NOREF'.
          APPEND t_noref.
***end of Tempo addition
          DELETE ft_vbrk0.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Get Cancel Return and exclude it
  IF NOT t_vbfacr[] IS INITIAL.
    LOOP AT t_vbfacr.

      READ TABLE ft_vbrk0 WITH KEY vbeln = t_vbfacr-vbelv.
      IF sy-subrc = 0.
        DELETE ft_vbrk0 INDEX sy-tabix.
      ENDIF.

***added for Tempo to accomodate CREATE WITH NO REFERENCE
      READ TABLE t_noref WITH KEY vbeln = t_vbfacr-vbelv.
      IF sy-subrc = 0.
        DELETE t_noref INDEX sy-tabix.
      ENDIF.
***end of Tempo addition

    ENDLOOP.
  ENDIF.

* Get Cancel Billing and Excule it
  IF NOT t_vbfacc[] IS INITIAL.
    LOOP AT t_vbfacc.

      READ TABLE ft_vbrk0 WITH KEY vbeln = t_vbfacc-vbelv.
      IF sy-subrc = 0.
        DELETE ft_vbrk0 INDEX sy-tabix.
      ENDIF.

***added for Tempo to accomodate CREATE WITH NO REFERENCE
      READ TABLE t_noref WITH KEY vbeln = t_vbfacc-vbelv.
      IF sy-subrc = 0.
        DELETE t_noref INDEX sy-tabix.
      ENDIF.
***end of Tempo addition

    ENDLOOP.
  ENDIF.

* Get Cancel
  BREAK bcrmd.
  IF NOT t_vbfaca[] IS INITIAL.

    SORT t_vbfaca BY vbelv.

    DATA: lt_vbfaca1 LIKE t_vbfaca,
          ld_found,
          ld_tbx_dl  LIKE sy-tabix.

*           to handle cancellation billing that delivery note had been
*           deleted, so link in order flow will be gone
    LOOP AT t_vbfaca WHERE vbtyp_v = 'M' OR
***added for Tempo --- treat Debit memo as Normal billing
                           vbtyp_v = 'P'.
***end of Tempo addition
      lt_vbfaca1 = t_vbfaca.

      AT NEW vbelv.

      ENDAT.
      CLEAR ld_found.
      READ TABLE ft_vbrk0 WITH KEY vbeln = lt_vbfaca1-vbeln
                                   vbelv = space.
      IF sy-subrc = 0.
        ld_tbx_dl = sy-tabix.
        CLEAR: zgdtxdt0002-vbeln.
        SELECT SINGLE vbeln fakturno
               INTO (zgdtxdt0002-vbeln, zgdtxdt0002-fakturno)
               FROM zgdtxdt0002
               WHERE vbeln = lt_vbfaca1-vbelv.
        IF sy-subrc = 0.
          SELECT SINGLE faktur_type fakdat
           INTO  (zgdtxdt0003-faktur_type, zgdtxdt0003-fakdat)
           FROM  zgdtxdt0003
           WHERE fakturno = zgdtxdt0002-fakturno.
          IF sy-subrc = 0.
            ft_vbrk0-faktur_type = zgdtxdt0003-faktur_type.
            ld_found = 'X'.
          ENDIF.
        ENDIF.
        IF ld_found = 'X'.
          ft_vbrk0-vbelv = lt_vbfaca1-vbelv.
          ft_vbrk0-posnv = lt_vbfaca1-posnv.
          MODIFY ft_vbrk0 INDEX sy-tabix.
        ELSE.
          MOVE-CORRESPONDING ft_vbrk0 TO t_error.
          t_error-msg = 'Billing Normal has not been processed'.
          APPEND t_error.
*          delete t_vbfaca.
          DELETE ft_vbrk0 INDEX ld_tbx_dl.
*          CONTINUE.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDIF.

ENDFORM.                    " F_GET_BILL


*---------------------------------------------------------------------*
*       FORM f_collect_bill                                           *
*---------------------------------------------------------------------*
FORM f_collect_bill
     TABLES   ft_vbrk0 STRUCTURE t_vbrk0.

  DATA ld_closedat LIKE zgdtxdt0004-closedat.
  DATA ld_masatx LIKE zgdtxdt0004-masatx.
  DATA ld_masatxs LIKE zgdtxdt0002-masatx.
  DATA ld_fkdat_norm(6) TYPE c.
  DATA ld_fkdat_anak(6) TYPE c.
  DATA ld_tabix LIKE sy-tabix.
  DATA ld_flag_notaretur.
  DATA ld_noref.
*  DATA p_0004(1) TYPE c.
*  CLEAR: p_0004.

  BREAK bcrmd.
*--- Get Display Table.
  LOOP AT ft_vbrk0 .

    ld_tabix = sy-tabix.
    CLEAR:
      zgdtxdt0002-fkdat,
      zgdtxdt0002-fakturno,
      t_crtfakturpajak,
      t_notaretur,
      ld_noref.

    SELECT SINGLE fkdat fakturno masatx
           INTO (zgdtxdt0002-fkdat, zgdtxdt0002-fakturno,
                 zgdtxdt0002-masatx)
           FROM zgdtxdt0002
           WHERE vbeln = ft_vbrk0-vbelv.  "*FIX
    IF sy-subrc = 0.
      ld_fkdat_norm = zgdtxdt0002-fkdat+0(6).
      t_vbrk0-fakturno = zgdtxdt0002-fakturno.
      ld_masatxs = zgdtxdt0002-masatx.
      IF zgdtxdt0002-fakturno = space.
        DELETE ft_vbrk0.                 "*FIX
        CONTINUE.
      ENDIF.
***added for Tempo -- to cater RETURN WITHOUT REFERENCE (OLD DATA)
    ELSE.
      ld_noref = 'X'.
      ld_masatxs = ft_vbrk0-fkdat(6).
***end addition
    ENDIF.

    CLEAR zgdtxdt0003.
***modified for Tempo -- to cater RETURN WITHOUT REFERENCE (OLD DATA)
    IF ld_noref = 'X'.
      CLEAR d_fakno_screen.
      IF zgdtxdt0002-masatx(4) GT 2006.
***        CALL SCREEN 3100 STARTING AT 5 5  ENDING AT 76 10.
        CALL SCREEN 3200 STARTING AT 5 5  ENDING AT 76 10.
      ELSE.
        IF radio1 EQ 'X'.
          CALL SCREEN 3000 STARTING AT 5 5  ENDING AT 76 10.
        ELSE.
          CALL SCREEN 3200 STARTING AT 5 5  ENDING AT 76 10.
        ENDIF.
      ENDIF.
      IF sy-ucomm = 'NO'.
        STOP.
      ENDIF.
    ELSE.
      SELECT SINGLE *
             FROM zgdtxdt0003
             WHERE fakturno = zgdtxdt0002-fakturno.
    ENDIF.
***end of Tempo modification
*---- Checking Close Date
    ld_fkdat_anak = ft_vbrk0-fkdat+0(6).

****removed for Tempo since the process will always Nota retur
*    IF ld_fkdat_anak > ld_masatxs.  "Closed Period
*****changed for MKM 09/02/2004
**      IF ft_vbrk0-fkart IN r_fkartp.
**        ld_flag_notaretur = 'C'.         "Create FP
**        ft_vbrk0-fakdat = t_vbrk0-fkdat.
**      ELSEIF ft_vbrk0-fkart IN r_fkartc OR
*      IF ft_vbrk0-fkart IN r_fkartc OR
*         ft_vbrk0-fkart IN r_fkartr OR
****modified for Credit memo only by Rahmadi 16/07/2004
****so Debit memo will be considered using new FP
**         ft_vbrk0-fkart IN r_fkartp  "added for MKM 09/02/2004
*         ( ft_vbrk0-fkart IN r_fkartp AND
*           ft_vbrk0-vbtyp = 'O' ).
****end of modification
*        ld_flag_notaretur = 'N'.         "Nota Retur
*        ft_vbrk0-fakdat = t_vbrk0-fkdat.
****added by Rahmadi 16/07/2004 for Debit memo
*      ELSEIF ft_vbrk0-fkart IN r_fkartp AND
*             ft_vbrk0-vbtyp = 'P' .
*        ld_flag_notaretur = 'C'.         "Create New FP
*        ft_vbrk0-fakdat = t_vbrk0-fkdat.
****end of addition
*      ELSE.                              "mkm Price Adj.
*        ld_flag_notaretur = 'P'.         "Pembetulan
*        ft_vbrk0-fakdat = zgdtxdt0003-fakdat.
*      ENDIF.
*    ELSE.
*      ld_flag_notaretur = 'P'.         "Pembetulan
*      ft_vbrk0-fakdat = zgdtxdt0003-fakdat.
*    ENDIF.
****end of Tempo removal

****added for Tempo -- the process will always be Nota Retur
    ld_flag_notaretur = 'N'.         "Nota Retur
    IF ld_noref = 'X'.
      ft_vbrk0-fakdat = ft_vbrk0-fkdat.
      ft_vbrk0-faktur_type = c_sat.
      ft_vbrk0-kunnr = ft_vbrk0-kunrg.
    ELSE.
      ft_vbrk0-fakdat = ft_vbrk0-fkdat.      "*FIX
    ENDIF.
****end of Tempo addition
    MODIFY ft_vbrk0 INDEX ld_tabix
           TRANSPORTING fakdat.

    CLEAR: t_vbrkscr, t_notaretur.
    MOVE-CORRESPONDING ft_vbrk0 TO t_vbrkscr.
***modified for Tempo to cater Create without Reference
    IF ld_noref = 'X'.
      t_vbrkscr-fktno = d_fakno_screen.
    ELSE.
      t_vbrkscr-fktno = ft_vbrk0-fakturno.    "*FIX
    ENDIF.
****added by Rahmadi
    t_vbrkscr-masatx = ld_masatxs.
****end of addition

    IF ld_flag_notaretur = 'N'.        "Nota Retur
      t_vbrkscr-memo = 'Nota Retur'.
      MOVE-CORRESPONDING ft_vbrk0 TO t_notaretur.
***modified for Tempo to cater Create without Reference
      IF ld_noref = 'X'.
        t_notaretur-fakturno = d_fakno_screen.
      ELSE.
        t_notaretur-fakturno = ft_vbrk0-fakturno.    "*FIX
      ENDIF.
***end of Tempo modification

*       Create Faktur Pajak if Billing Price adjustment
*       is higher than original price for KTB Only.
    ELSEIF ld_flag_notaretur = 'C'.        "Create New Faktur Pajak
      SELECT SINGLE netwr mwsbk
             FROM   vbrk
             INTO   (vbrk-netwr,vbrk-mwsbk)
             WHERE  vbeln = ft_vbrk0-vbeln.
      IF sy-subrc = 0.
*        IF vbrk-netwr < 0.    "changed for MKM 09/02/2004
        t_vbrkscr-memo = 'Create Faktur Pajak'.
        MOVE-CORRESPONDING ft_vbrk0 TO t_crtfakturpajak.
        t_crtfakturpajak-fkart     = 'ZXXX'.
        t_crtfakturpajak-fakturno  = ft_vbrk0-fakturno.    "*FIX
        t_crtfakturpajak-itamtlast = vbrk-netwr.
        t_crtfakturpajak-ppnlast   = vbrk-mwsbk.
***added by Rahmadi 16/07/2004 for Debit memo
        t_crtfakturpajak-fakgr     = zgdtxdt0003-fakgr.
***end of addition
****changed for MKM 09/02/2004
*        ELSE.
*          MOVE-CORRESPONDING ft_vbrk0 TO t_error.
*          t_error-msg =
*          'Price Adjustment is lower than price in billing normal'.
*          APPEND t_error.
*          DELETE ft_vbrk0 INDEX ld_tabix.
*          CONTINUE.
*        ENDIF.
****end of change
      ENDIF.
    ENDIF.

    CASE ft_vbrk0-faktur_type.
      WHEN c_sat.
        t_vbrkscr_sat = t_vbrkscr.
***added for tempo to identify create with no reference
        t_vbrkscr_sat-noref = ld_noref.
***end of tempo addition
        COLLECT t_vbrkscr_sat.
        IF NOT t_crtfakturpajak IS INITIAL.
          t_crtfakturpajak_sat = t_crtfakturpajak.
***added for tempo to identify create with no reference
          t_crtfakturpajak_sat-noref = ld_noref.
***end of tempo addition
          APPEND t_crtfakturpajak_sat.
        ENDIF.
        IF NOT t_notaretur IS INITIAL.
          t_notaretur_sat = t_notaretur.
***added for tempo to identify create with no reference
          t_notaretur_sat-noref = ld_noref.
***end of tempo addition
          APPEND t_notaretur_sat.
        ENDIF.
      WHEN c_gab.
        t_vbrkscr_gab = t_vbrkscr.
        COLLECT t_vbrkscr_gab.
        IF NOT t_crtfakturpajak IS INITIAL.
          t_crtfakturpajak_gab = t_crtfakturpajak.
          APPEND t_crtfakturpajak_gab.
        ENDIF.
        IF NOT t_notaretur IS INITIAL.
          t_notaretur_gab = t_notaretur.
          APPEND t_notaretur_gab.
        ENDIF.
      WHEN c_sp1 OR c_sp2 OR c_sp3.
        t_vbrkscr_split = t_vbrkscr.
        COLLECT t_vbrkscr_split.
        IF NOT t_crtfakturpajak IS INITIAL.
          t_crtfakturpajak_split = t_crtfakturpajak.
          APPEND t_crtfakturpajak_split.
        ENDIF.
        IF NOT t_notaretur IS INITIAL.
          t_notaretur_split = t_notaretur.
          APPEND t_notaretur_split.
        ENDIF.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    " F_COLLECT_BILL

*&---------------------------------------------------------------------*
*&      Form  F_SATUAN
*&---------------------------------------------------------------------*
FORM f_satuan.
  t_vbrkscr[]        = t_vbrkscr_sat[].
  t_notaretur[]      = t_notaretur_sat[].
  t_crtfakturpajak[] = t_crtfakturpajak_sat[].

ENDFORM.                    " F_SATUAN

*---------------------------------------------------------------------*
*       FORM f_gabungan                                               *
*---------------------------------------------------------------------*
FORM f_gabungan.
  t_vbrkscr[]        = t_vbrkscr_gab[].
  t_notaretur[]      = t_notaretur_gab[].
  t_crtfakturpajak[] = t_crtfakturpajak_gab[].

ENDFORM.                    " F_SATUAN

*---------------------------------------------------------------------*
*       FORM f_split                                                  *
*---------------------------------------------------------------------*
FORM f_split.
  t_vbrkscr[]        = t_vbrkscr_split[].
  t_notaretur[]      = t_notaretur_split[].
  t_crtfakturpajak[] = t_crtfakturpajak_split[].

ENDFORM.                    " F_SATUAN

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS
*&---------------------------------------------------------------------*
FORM f_process TABLES  ft_vbrkscr STRUCTURE t_vbrkscr.

  DATA: ld_subrc LIKE sy-subrc.

  PERFORM f_selected_datas CHANGING ld_subrc.

  IF ld_subrc = 0.
    CASE tabstrip-activetab.
      WHEN 'SATUAN'.
        PERFORM f_export_satuan TABLES t_vbrkscr.
      WHEN 'GABUNGAN'.
        PERFORM f_export_gabungan TABLES t_vbrkscr.
*        MESSAGE i000 WITH 'Under construction'.
      WHEN 'SPLIT'.
        PERFORM f_export_split TABLES t_vbrkscr.
    ENDCASE.
  ELSE.
    MESSAGE i000 WITH 'Please Select Records'.
  ENDIF.
ENDFORM.                    " F_PROCESS

*---------------------------------------------------------------------*
*       FORM f_proc_notaretur_crtfakturpjk                            *
*---------------------------------------------------------------------*
FORM f_proc_notaretur_crtfakturpjk
     TABLES   ft_vbrkscr STRUCTURE t_vbrkscr.

  DATA: lt_notaretur LIKE t_notaretur OCCURS 0 WITH HEADER LINE.

* Process Nota Retur
* khusus nota retur tdk di passing
  BREAK bcrmd.
  IF NOT t_notaretur[] IS INITIAL.
    lt_notaretur[] = t_notaretur[].
    PERFORM f_process_notaretur.
    t_notaretur[] = lt_notaretur[].
  ENDIF.

* Process Create Faktur Pajak
  IF NOT t_crtfakturpajak[] IS INITIAL.
    PERFORM f_crtfakturpajak_process.
  ENDIF.

*-- Exclude Billing Nota Retur & Billing Crt Faktur Pajak.
  DATA: ld_tabix LIKE sy-tabix.
  LOOP AT ft_vbrkscr.
    ld_tabix = sy-tabix.
    READ TABLE t_notaretur WITH KEY vbeln = ft_vbrkscr-vbeln.
    IF sy-subrc = 0.
****removed for MKM 09/02/2004
*      IF NOT t_notaretur-fkart IN r_fkartp.

      DELETE ft_vbrkscr INDEX ld_tabix.
*      ENDIF.
****end of removal
    ENDIF.
    READ TABLE t_crtfakturpajak WITH KEY vbeln = ft_vbrkscr-vbeln.
    IF sy-subrc = 0.
      DELETE ft_vbrkscr INDEX ld_tabix.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "f_proc_notaretur_crtfakturpjk

*&---------------------------------------------------------------------*
*&      Form  F_EXPORT_SATUAN
*&---------------------------------------------------------------------*
FORM f_export_satuan TABLES   ft_vbrkscr STRUCTURE t_vbrkscr.

  DATA: ld_subrc LIKE sy-subrc,
        ld_lines TYPE i.

  PERFORM f_proc_notaretur_crtfakturpjk
          TABLES ft_vbrkscr.

  IF NOT ft_vbrkscr[] IS INITIAL.

    PERFORM f_selected_datas CHANGING ld_subrc.

    IF t_vbrkscr1[] IS INITIAL.
      EXIT.
    ENDIF.

    IF ld_subrc = 0.

      PERFORM f_get_range TABLES  t_vbrkscr1.

*       Right now, user can not select all and process for pembetulan /
*       correction, but select one by one and process. So t_vbrkscr1
*       will only contain one data.
      CLEAR t_vbrkscr1.
      READ TABLE t_vbrkscr1 INDEX 1.

*** added by Rahmadi
*---RPC process will consistently use Invoice consolidation option
*---selected when the original Faktur Pajak created
      DATA ld_fakgr.
      CLEAR ld_fakgr.
      SELECT SINGLE fakgr
             INTO ld_fakgr
             FROM zgdtxdt0003
             WHERE bukrs = p_bukrs AND
                   brnch = p_brnch AND
                   busln = p_busln AND
                   fakturno = t_vbrkscr1-fktno AND
                   masatx = t_vbrkscr1-masatx AND
                   batal = ''.
*** end of addition

      SUBMIT zgdtx_e0002 "VIA SELECTION-SCREEN
*** Added by Rahmadi
*---Organization structure adjustment
                           WITH p_brnch  EQ p_brnch
                           WITH p_busln  EQ p_busln
                           WITH p_flag   EQ ld_fakgr
                           WITH p_mpage  EQ p_mpage
                           WITH p_dest   EQ p_dest
*** End of addition
*                           WITH p_vkorg  EQ p_vkorg
*                           WITH p_gsber  EQ p_gsber
*                           WITH p_spart  EQ p_spart
                           WITH s_fkdat  IN r_fkdat
                           WITH s_stceg  IN r_stceg
                           WITH s_vbeln  IN r_vbeln
                           WITH p_fakdat EQ t_vbrkscr1-fakdat
                           WITH s_pstyv  IN r_pstyv
                           WITH p_rpc    EQ d_rpc
                           WITH p_top    EQ ''
****added for Tempo to accomodate external Nota Retur
                           WITH p_noret  EQ p_noret
****end of Tempo addition
                           AND RETURN.
      LEAVE TO SCREEN 0.

    ENDIF.
  ENDIF.
ENDFORM.                    " F_EXPORT_SATUAN


*&---------------------------------------------------------------------*
*&      Form  F_EXPORT_GABUNGAN
*&---------------------------------------------------------------------*
FORM f_export_gabungan TABLES   ft_vbrkscr STRUCTURE t_vbrkscr.

  PERFORM f_proc_notaretur_crtfakturpjk
          TABLES ft_vbrkscr.

  DATA: ld_subrc LIKE sy-subrc,
        ld_lines TYPE i.

  IF NOT ft_vbrkscr[] IS INITIAL.

    PERFORM f_selected_datas CHANGING ld_subrc.

    IF t_vbrkscr1[] IS INITIAL.
      EXIT.
    ENDIF.

    PERFORM f_get_range TABLES  t_vbrkscr1.

*    IF p_spart = '03'.
**       Right now, user can not select all and process for pembetulan /
**       correction, but select one by one and process. So t_vbrkscr1
**       will only contain one data.
*      CLEAR t_vbrkscr1.
*      READ TABLE t_vbrkscr1 INDEX 1.
*
**** added by Rahmadi
**---RPC process will consistently use Invoice consolidation option
**---selected when the original Faktur Pajak created
*      DATA ld_fakgr.
*      CLEAR ld_fakgr.
*      SELECT SINGLE fakgr
*             INTO ld_fakgr
*             FROM zGDTXdt0003
*             WHERE bukrs = p_bukrs AND
*                   brnch = p_brnch AND
*                   busln = p_busln AND
*                   fakturno = t_vbrkscr1-fktno AND
*                   masatx = t_vbrkscr1-masatx AND
*                   batal = ''.
**** end of addition
*
*      SUBMIT zGDTX_e0003 "VIA SELECTION-SCREEN
**** Added by Rahmadi
**---Organization structure adjustment
*                           WITH p_brnch  EQ p_brnch
*                           WITH p_busln  EQ p_busln
*                           WITH p_flag   EQ ld_fakgr
*                           WITH p_mpage  EQ p_mpage
**** End of addition
*                           WITH p_vkorg  EQ p_vkorg
*                           WITH p_gsber  EQ p_gsber
*                           WITH p_spart  EQ p_spart
*                           WITH s_fkdat  IN r_fkdat
*                           WITH s_stceg  IN r_stceg
*                           WITH s_vbeln  IN r_vbeln
*                           WITH p_fakdat EQ t_vbrkscr1-fakdat
*                           WITH s_pstyv  IN r_pstyv
*                           WITH p_rpc    EQ d_rpc
*                           WITH p_top    EQ ''
*                           AND RETURN.
*      SET SCREEN 0.
*    ELSE.

    CLEAR t_vbrkscr1.
    READ TABLE t_vbrkscr1 INDEX 1.

*** added by Rahmadi
*---RPC process will consistently use Invoice consolidation option
*---selected when the original Faktur Pajak created
    DATA ld_fakgr.
    CLEAR ld_fakgr.
    SELECT SINGLE fakgr
           INTO ld_fakgr
           FROM zgdtxdt0003
           WHERE bukrs = p_bukrs AND
                 brnch = p_brnch AND
                 busln = p_busln AND
                 fakturno = t_vbrkscr1-fktno AND
                 masatx = t_vbrkscr1-masatx AND
                 batal = ''.
*** end of addition

    SUBMIT zgdtx_e0003 "VIA SELECTION-SCREEN
*** Added by Rahmadi
*---Organization structure adjustment
                         WITH p_brnch  EQ p_brnch
                         WITH p_busln  EQ p_busln
                         WITH p_flag   EQ ld_fakgr
                         WITH p_mpage  EQ p_mpage
                         WITH p_dest   EQ p_dest

*** End of addition
*                           WITH p_vkorg  EQ  p_vkorg
*                           WITH p_gsber  EQ p_gsber
*                           WITH p_spart  EQ p_spart
                         WITH s_fkdat  IN r_fkdat
                         WITH s_stceg  IN r_stceg
                         WITH s_vbeln  IN r_vbeln
                         WITH p_fakdat EQ t_vbrkscr1-fakdat
                         WITH p_rpc    EQ d_rpc
                         WITH p_top    EQ ''
                         AND RETURN.
    SET SCREEN 0.
*    ENDIF.
  ELSE.
*    MESSAGE i000 WITH 'No Data To Be Processed'.
  ENDIF.

ENDFORM.                    " F_EXPORT_GABUNGAN

*&---------------------------------------------------------------------*
*&      Form  F_EXPORT_SPLIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_VBRKSCR  text
*----------------------------------------------------------------------*
FORM f_export_split TABLES   ft_vbrkscr STRUCTURE t_vbrkscr.

  DATA: ld_subrc    LIKE sy-subrc,
        ld_linevbrk TYPE i,
        ld_line     TYPE i.

  DATA: p_sp_qty(1) TYPE c,
        p_sp_amo(1) TYPE c,
        p_sp_ite(1) TYPE c.

  REFRESH r_vbeln.

*--- Validation For Unit Only / Division '01'
  IF p_spart <> '01'.
    MESSAGE i000 WITH 'Split Only for Unit'.
    EXIT.
  ENDIF.

  t_vbrkscritm[] = t_vbrkscr[].
  DELETE t_vbrkscritm WHERE sel = space.
  DESCRIBE TABLE t_vbrkscritm LINES ld_line.
  IF ld_line = 0.
    MESSAGE i000 WITH 'No Data Selected'.
    EXIT.
  ELSEIF ld_line > 1.
    MESSAGE i000 WITH 'Please Select Only Single Records'.
    EXIT.
  ENDIF.

*--- Only One Records can be process.
  LOOP AT t_notaretur.
    READ TABLE t_vbrkscritm WITH KEY vbeln = t_notaretur-vbeln.
    IF sy-subrc <> 0.
      DELETE t_notaretur.
    ENDIF.
  ENDLOOP.

*--- Process Nota Retur
  IF NOT t_notaretur[] IS INITIAL.
    PERFORM f_process_notaretur.
  ENDIF.

*-- Exclude Billing Nota Retur.
  LOOP AT ft_vbrkscr.
    READ TABLE t_notaretur WITH KEY vbeln = ft_vbrkscr-vbeln.
    IF sy-subrc = 0.
****removed for MKM 09/02/2004
*      IF NOT t_notaretur-fkart IN r_fkartp.
      DELETE ft_vbrkscr.
*      ENDIF.
****end of removal
    ENDIF.
  ENDLOOP.


  DATA ft_vbrkscrdummy LIKE ft_vbrkscr OCCURS 1 WITH HEADER LINE.

  IF NOT ft_vbrkscr[] IS INITIAL.

    ft_vbrkscrdummy[] = ft_vbrkscr[].
    DELETE ft_vbrkscrdummy[] WHERE sel = space.
    DESCRIBE TABLE ft_vbrkscrdummy LINES ld_linevbrk.

    IF ld_linevbrk = 1.

      READ TABLE ft_vbrkscrdummy INDEX 1.
      IF sy-subrc = 0.

        READ TABLE t_vbrk0 WITH KEY vbeln = ft_vbrkscrdummy-vbeln.
        IF sy-subrc = 0.

*--- Get Faktur No
          r_fakturno-sign = 'I'.
          r_fakturno-option = 'EQ'.
          r_fakturno-low = t_vbrk0-fakturno.
          APPEND r_fakturno.

          CASE t_vbrk0-faktur_type.
            WHEN 'A'.
              p_sp_qty = space.
              p_sp_amo = 'X'.
              p_sp_ite = space.
            WHEN 'Q'.
              p_sp_qty = 'X'.
              p_sp_amo = space.
              p_sp_ite = space.
            WHEN 'I'.
              p_sp_qty = space.
              p_sp_amo = space.
              p_sp_ite = 'X'.
          ENDCASE.
        ENDIF.

**** Get Billing Normal.
        r_vbeln-sign = 'I'.
        r_vbeln-option = 'EQ'.
        r_vbeln-low = ft_vbrkscr-vbelv.
        APPEND r_vbeln.

        SUBMIT zgdtx_e0004 "VIA SELECTION-SCREEN
                             WITH s_vbeln  IN r_vbeln
                             WITH p_fakdat EQ t_vbrk0-fakdat
                             WITH p_sp_qty EQ p_sp_qty
                             WITH p_sp_amo EQ p_sp_amo
                             WITH p_sp_ite EQ p_sp_ite
                             WITH p_rpc    EQ d_rpc
                             WITH p_top    EQ ''
                             AND RETURN.
        SET SCREEN 0.

        REFRESH t_notaretur[].
        t_notaretur[] = t_notareturdummy[].
      ENDIF.
    ELSE.
      MESSAGE i000 WITH 'Please Select Only One Record'.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_EXPORT_SATUAN

*&---------------------------------------------------------------------*
*&      Form  F_GET_RANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FT_VBRKSCR  text
*----------------------------------------------------------------------*
FORM f_get_range TABLES    ft_vbrkscr1 STRUCTURE t_vbrkscr1.

  DATA: BEGIN OF ft_vbeln OCCURS 1.
  DATA: vbeln LIKE zgdtxdt0002-vbeln,
        fkdat LIKE zgdtxdt0002-fkdat.
  DATA END OF ft_vbeln.

  DATA: ld_tanggal      LIKE vbrk-fkdat,
        ld_tanggal1     LIKE vbrk-fkdat,
        ld_tanggal_low  LIKE vbrk-fkdat,
        ld_tanggal_high LIKE vbrk-fkdat.

  DATA: lt_vbrkscr1 LIKE ft_vbrkscr1,
        ff_vbeln    LIKE ft_vbeln,
        ld_fakturno LIKE zgdtxdt0002-fakturno.

  REFRESH: r_fkdat,
           r_stceg,
           r_vbeln,
           r_fakturno,
           r_pstyv.

  r_pstyv-sign   = 'I'.
  r_pstyv-option = 'EQ'.
  SORT t_vbrk0 BY vbeln.

  LOOP AT ft_vbrkscr1.

    lt_vbrkscr1 = ft_vbrkscr1.
**** Get Range Billing Date.
    IF tabstrip-activetab = 'SATUAN'.
      AT FIRST.
        CLEAR: zgdtxdt0002-fkdat.
        SELECT SINGLE fkdat
               INTO zgdtxdt0002-fkdat
               FROM zgdtxdt0002
               WHERE vbeln = lt_vbrkscr1-vbelv.
        IF sy-subrc = 0.
          ld_tanggal = zgdtxdt0002-fkdat.
        ENDIF.
      ENDAT.

      IF zgdtxdt0002-fkdat <= ld_tanggal.
        ld_tanggal_low =  zgdtxdt0002-fkdat.
      ELSE.
        ld_tanggal1 =  zgdtxdt0002-fkdat.
      ENDIF.

      IF  zgdtxdt0002-fkdat >= ld_tanggal1.
        ld_tanggal_high =  zgdtxdt0002-fkdat.
      ENDIF.
    ENDIF.

    IF tabstrip-activetab <> 'SATUAN'.
**** Get Range NPWP.
      r_stceg-sign = 'I'.
      r_stceg-option = 'EQ'.
      r_stceg-low = ft_vbrkscr1-stceg.
      APPEND r_stceg.
    ENDIF.

    IF tabstrip-activetab = 'SATUAN'.
**** Get Range Billing Normal.
      r_vbeln-sign = 'I'.
      r_vbeln-option = 'EQ'.
      r_vbeln-low = ft_vbrkscr1-vbelv.
      APPEND r_vbeln.
    ELSEIF tabstrip-activetab = 'GABUNGAN'.
      CLEAR: ld_fakturno.
      SELECT SINGLE fakturno
             INTO ld_fakturno
             FROM zgdtxdt0002
             WHERE vbeln = ft_vbrkscr1-vbelv.
      IF sy-subrc = 0.
*        SELECT vbeln fkdat
*               INTO CORRESPONDING FIELDS OF TABLE ft_vbeln
*               FROM zgdtxdt0002
*               WHERE fakturno = ld_fakturno
*                 AND fkart IN r_fkartn.
        "Start SOH: Shell SCI Adjustment 20240222 RZL
        SELECT vbeln fkdat
               INTO CORRESPONDING FIELDS OF TABLE ft_vbeln
               FROM zgdtxdt0002
               WHERE fakturno = ld_fakturno
                 AND fkart IN r_fkartn ORDER BY PRIMARY KEY.
        "End SOH: Shell SCI Adjustment 20240222 RZL
        IF NOT ft_vbeln[] IS INITIAL.
          LOOP AT ft_vbeln.

            ff_vbeln = ft_vbeln.

            AT FIRST.
              ld_tanggal = ff_vbeln-fkdat.
            ENDAT.

            r_vbeln-sign = 'I'.
            r_vbeln-option = 'EQ'.
            r_vbeln-low = ff_vbeln-vbeln.
            APPEND r_vbeln.

            IF ff_vbeln-fkdat <= ld_tanggal.
              ld_tanggal_low =  ff_vbeln-fkdat.
            ELSE.
              ld_tanggal1 =  ff_vbeln-fkdat.
            ENDIF.

            IF  ff_vbeln-fkdat >= ld_tanggal1.
              ld_tanggal_high =  ff_vbeln-fkdat.
            ENDIF.

          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.

    DELETE ADJACENT DUPLICATES FROM r_vbeln COMPARING ALL FIELDS.
    DELETE ADJACENT DUPLICATES FROM r_stceg COMPARING ALL FIELDS.

****Get Range Faktur No.
    READ TABLE t_vbrk0 WITH KEY vbeln = ft_vbrkscr1-vbeln.
    IF sy-subrc = 0.
      r_fakturno-sign = 'I'.
      r_fakturno-option = 'EQ'.
      r_fakturno-low = t_vbrk0-fakturno.
      APPEND r_fakturno.
    ENDIF.

****Get PSTYV
    READ TABLE t_vbrk0 WITH KEY vbeln = ft_vbrkscr1-vbeln
         BINARY SEARCH.
    r_pstyv-low = t_vbrk0-pstyv.
    APPEND r_pstyv.
  ENDLOOP.

  SORT r_pstyv BY low.
  DELETE ADJACENT DUPLICATES FROM r_pstyv COMPARING low.

**Get Range Billing Date.
  r_fkdat-sign = 'I'.
  r_fkdat-option = 'EQ'.
  r_fkdat-low = ld_tanggal_low.
  r_fkdat-high = ld_tanggal_high.
  APPEND r_fkdat.

ENDFORM.                    " F_GET_RANGE


*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_BILL_NORMAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_VBRK0  text
*----------------------------------------------------------------------*
FORM f_collect_bill_normal TABLES   ft_vbrk0 STRUCTURE t_vbrk0.

  t_vbrkn[] = t_vbrk0[].
  IF NOT s_vbeln[] IS INITIAL.
    LOOP AT s_vbeln.
      READ TABLE t_vbrk0 WITH KEY vbeln = s_vbeln-low.
      IF sy-subrc = 0.
        IF t_vbrk0-fkart IN r_fkartn.
          MOVE-CORRESPONDING ft_vbrk0 TO t_error.
          t_error-msg = 'This Billing is Normal Billing'.
          APPEND t_error.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  DELETE t_vbrkn WHERE NOT fkart IN r_fkartn.
  DELETE t_vbrk0 WHERE fkart IN r_fkartn.

ENDFORM.                    " F_COLLECT_BILL_NORMAL



*---------------------------------------------------------------------*
*       FORM f_exit_screens                                           *
*---------------------------------------------------------------------*
FORM f_exit_screens USING fu_dynnr.

  CASE fu_dynnr.
***added for Tempo --- NOREF
    WHEN '3000'.
      CLEAR: d_nofp, d_dynnr, d_fakno_screen.
      LEAVE TO SCREEN 0.

    WHEN '3100'.
      CLEAR: d_nofp1, d_nofp2, d_nofp3, d_nofp4, d_dynnr,
             d_fakno_screen.
      LEAVE TO SCREEN 0.

    WHEN '3200'.
      CLEAR: d_nofp1, d_nofp2, d_nofp3, d_nofp, d_dynnr,
             d_fakno_screen.
      LEAVE TO SCREEN 0.

***end of Tempo addition
  ENDCASE.

ENDFORM.                    "f_exit_screens



*&---------------------------------------------------------------------*
*&      Form  F_PREVIEW_USER_COMMANDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_preview_user_commands.

  CASE d_dynnr.
    WHEN '1600' OR '5000'.
      CASE sy-ucomm.
        WHEN 'ZBACK' OR 'ZCANC' OR 'ZEXIT'.
          PERFORM f_clear_data USING '02'.
***added by Rahmadi 16/07/2004 for debit note preview
          macro_init_ranges t_vbrk.
          macro_init_ranges t_vbrk1.
          macro_init_ranges t_priceall.
***end of addition
          LEAVE LIST-PROCESSING.
        WHEN 'PRINT'.
          PERFORM f_call_function USING ''
                                        'X'
                                        ''
                                        p_mpage
                                        p_dest
                                        space
                                        p_cust
                              CHANGING d_subrcp.
      ENDCASE.
  ENDCASE.


  CLEAR sy-ucomm.

ENDFORM.                    "f_preview_user_commands


*---------------------------------------------------------------------*
*       FORM f_faktur_dates                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  ft_fkdat                                                      *
*  -->  fu_fakdat                                                     *
*  -->  fu_vkorg                                                      *
*  -->  fu_gsber                                                      *
*---------------------------------------------------------------------*
FORM f_faktur_dates TABLES ft_fkdat STRUCTURE r_fkdat
                   USING  fu_fakdat
                          fu_vkorg
                          fu_gsber.
*                          fu_spart.

  DATA: ld_start LIKE sy-datum.

**Faktur pajak date must be >= latest billing date

  ld_start = ft_fkdat-low.
  ld_start+6(2) = '01'.

  IF ft_fkdat-high IS INITIAL.
    IF fu_fakdat < ld_start OR
       fu_fakdat < ft_fkdat-low.
      MESSAGE e505(zz) WITH ft_fkdat-low.
    ELSE.
      PERFORM f_check_closing_periods USING ft_fkdat-low+0(6)
                                           fu_vkorg
                                           fu_gsber.
    ENDIF.
  ELSE.
    IF fu_fakdat < ld_start OR
       fu_fakdat < ft_fkdat-high OR
       fu_fakdat < ft_fkdat-low.
      MESSAGE e505(zz) WITH ft_fkdat-high.
    ELSE.
      PERFORM f_check_closing_periods USING ft_fkdat-high+0(6)
                                           fu_vkorg
                                           fu_gsber.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_FAKTUR_DATE


*---------------------------------------------------------------------*
*       FORM f_check_closing_periods                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  fu_fakdat                                                     *
*  -->  fu_vkorg                                                      *
*  -->  fu_gsber                                                      *
*---------------------------------------------------------------------*
FORM f_check_closing_periods USING fu_fakdat
                                   fu_vkorg
                                   fu_gsber.
*                                  fu_spart.

  DATA ld_month(2) TYPE n.
  DATA ld_lastmonth(2) TYPE n.
  DATA ld_year(4) TYPE n.
  DATA ld_lastper LIKE zgdtxdt0004-masatx.
  DATA ld_closedat LIKE zgdtxdt0004-closedat.
  DATA ld_masatx LIKE zgdtxdt0004-masatx.

**Faktur date should not be within a closed period
**Check branch based closing period
  SELECT SINGLE masatx closedat INTO (ld_masatx,ld_closedat)
                                FROM zgdtxdt0004
                                WHERE vkorg = fu_vkorg AND
                                      gsber = fu_gsber AND
*                                      spart = fu_spart AND
                                      masatx = fu_fakdat.
  IF sy-subrc = 0.
    IF ld_closedat <> '00000000'.
      MESSAGE e506(zz) WITH ld_masatx.
    ENDIF.
  ELSE.
    ld_month = fu_fakdat+4(2).
    ld_year = fu_fakdat+0(4).
    ld_lastmonth = ld_month - 1.
    IF ld_lastmonth = '00'.
      ld_lastmonth = '12'.
      ld_year = ld_year - 1.
    ENDIF.

    CONCATENATE ld_year ld_lastmonth INTO ld_lastper.
    MESSAGE e507(zz) WITH ld_lastper.
  ENDIF.

ENDFORM.                    " F_CHECK_CLOSING_PERIOD


*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_SEL
*&---------------------------------------------------------------------*
FORM f_clear_sel.
  LOOP AT t_vbrkscr WHERE sel = 'X'.
    t_vbrkscr-sel = space.
    MODIFY t_vbrkscr.
  ENDLOOP.
ENDFORM.                    " F_CLEAR_SEL

*---------------------------------------------------------------------*
*       FORM f_collect_billing_infos                                  *
*---------------------------------------------------------------------*
FORM f_collect_billing_infos TABLES ft_fkdat STRUCTURE r_fkdat
                                   ft_stceg STRUCTURE r_stceg
                             USING fu_vkorg
                                   fu_gsber
                                   fu_spart
                                   fu_brnch
                                   fu_busln
                                   fu_bukrs.


  DATA ld_tabix LIKE sy-tabix.
  DATA ld_subrc0 LIKE sy-subrc.
  DATA ld_subrc1 LIKE sy-subrc.
  DATA ld_subrc2 LIKE sy-subrc.
  DATA ld_subrc3 LIKE sy-subrc.
  DATA ld_subrc4 LIKE sy-subrc.
  DATA ld_flagerr.

  DATA lw_vbrk LIKE t_vbrk.
  DATA lt_vbrkfx LIKE t_vbrk OCCURS 1 WITH HEADER LINE.

  CLEAR: t_vbfac, t_vbfaa, ld_flagerr, t_error.
  REFRESH: t_vbfac, t_vbfaa.

  BREAK bcrmd.
**Get processed billing
  PERFORM f_get_processed_billing TABLES t_vbrk0
                                  USING fu_vkorg
                                        fu_gsber
                                        fu_spart
                                        fu_brnch
                                        fu_busln
                                        fu_bukrs.

***Changed for tempo --- get customer info for NOREF data
  IF NOT t_vbrk0[] IS INITIAL.
    PERFORM f_get_address_data TABLES t_vbrk0
                                      t_vbpa
                                      t_kna1
                                      t_adrc.
  ELSEIF NOT t_notaretur[] IS INITIAL.
    PERFORM f_get_address_data TABLES t_notaretur
                                      t_vbpa
                                      t_kna1
                                      t_adrc.
  ENDIF.
***end of Tempo changes

  LOOP AT t_notaretur.
    ld_tabix = sy-tabix.
    MOVE-CORRESPONDING t_notaretur TO lw_vbrk.

    IF ld_flagerr IS INITIAL.
      IF ld_subrc1 = 0.
********Check NPWP length must be > 10 chars
*        PERFORM f_check_npwp USING    lw_vbrk
*                             CHANGING ld_subrc2
*                                      lw_vbrk-stceg.
*        IF ld_subrc2 = 0.
**********Check whether Faktur has been processed for the billing
        PERFORM f_check_tax_done USING    lw_vbrk
                                          fu_vkorg
                                          fu_gsber
                                          fu_spart
                                 CHANGING ld_subrc4.
        IF ld_subrc4 = 0.
************Get CANCEL billing & ACCOUNTING documents
*            PERFORM f_get_canc_bill_acc_docs TABLES t_vbfac
*                                                    t_vbfaa
*                                             USING lw_vbrk-vbeln
*                                                   lw_vbrk-posnr.

          MOVE-CORRESPONDING lw_vbrk TO t_vbrk1.
          APPEND t_vbrk1.
        ELSE.
          ld_flagerr = 'X'.
        ENDIF.
*        ELSE.
*          ld_flagerr = 'X'.
*        ENDIF.
      ELSE.
        ld_flagerr = 'X'.
      ENDIF.
    ENDIF.

    AT END OF vbeln.
      IF NOT ld_flagerr IS INITIAL.
        READ TABLE t_vbrk1 WITH KEY vbeln = lw_vbrk-vbeln.
        IF sy-subrc = 0.
          DELETE t_vbrk1 WHERE vbeln = lw_vbrk-vbeln.
        ENDIF.
      ENDIF.
      CLEAR ld_flagerr.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " F_COLLECT_BILLING_INFOS

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATAS
*&---------------------------------------------------------------------*
FORM f_process_datas USING    fu_vkorg
                              fu_gsber
                              fu_spart
                              fu_brnch
                              fu_busln
                              fu_bukrs.
*                              fu_fakdat.

  DATA ld_tabixn LIKE sy-tabix.
  DATA ld_tabixp LIKE sy-tabix.
  DATA ld_tabixc LIKE sy-tabix.
  DATA ld_tabixx LIKE sy-tabix.
  DATA ld_subrcn LIKE sy-subrc.
  DATA ld_subrcp LIKE sy-subrc.
  DATA ld_subrcc LIKE sy-subrc.
  DATA ld_subrcx LIKE sy-subrc.
  DATA ld_flagerr.
  DATA ld_cancel.
  DATA lw_vbrk LIKE t_vbrk.
  DATA ld_tax LIKE konv-kbetr.
  DATA ld_vatin LIKE konv-kwert.
  DATA ld_vatout LIKE konv-kwert.
  DATA ld_cbelnr LIKE zgdtxdt0002-belnr.

  DATA lt_vbrkzero LIKE t_vbrk OCCURS 1 WITH HEADER LINE.
  DATA lt_unlock LIKE t_error OCCURS 1 WITH HEADER LINE.

  CHECK NOT t_vbrk1[] IS INITIAL.
  SORT t_vbrk1 BY vbeln posnr fkdat.

  LOOP AT t_vbrk1.
    MOVE-CORRESPONDING t_vbrk1 TO lw_vbrk.

    AT NEW vbeln.
      CLEAR: ld_flagerr, ld_cancel.
    ENDAT.

    IF ld_flagerr IS INITIAL.

*****modified by Rahmadi
*---not relevant
*********Check KWITANSI -- Only for SERVICE (Error if no kwitansi)
*      IF lw_vbrk-spart = d_service.
*        PERFORM f_get_kwitansi USING lw_vbrk
*                               CHANGING lw_vbrk-kwitansi
*                                        lw_vbrk-erdt2
*                                        ld_subrcn.
*      ELSE.
*        CLEAR ld_subrcn.
*      ENDIF.
      CLEAR ld_subrcn.
*****end of modification

      IF ld_subrcn = 0.
**********Check Cancel docs
        READ TABLE t_vbrkfc WITH KEY vbelv = lw_vbrk-vbeln
                                     posnv = lw_vbrk-posnr
                                     BINARY SEARCH.
        IF sy-subrc = 0.
          ld_tabixc = sy-tabix.
          PERFORM f_check_acc_docs USING  t_vbrkfc
                                          'C'
                                   CHANGING ld_cbelnr
                                            ld_subrcc.
          IF ld_subrcc = 0.
            PERFORM f_cancel_billing USING lw_vbrk.
            ld_cancel = 'X'.
          ENDIF.
        ENDIF.

**********NO cancel docs
        IF ld_cancel IS INITIAL.
************Get EQUIPMENT
          PERFORM f_get_equi USING lw_vbrk-ean11
                             CHANGING lw_vbrk-th_buat
                                      lw_vbrk-mesin.

************Get FAKTUR DATE
*          { Changed on 30 May 2002 - Delete p_fakdat
*          lw_vbrk-fakdat = fu_fakdat.

************Get MASATX
*          lw_vbrk-masatx = fu_fakdat+0(6).
*          lw_vbrk-gjahr = fu_fakdat+0(4).
          lw_vbrk-masatx = lw_vbrk-fakdat(6).
          lw_vbrk-gjahr = lw_vbrk-fakdat(4).

************Get WAPU
          PERFORM f_get_wapu USING    lw_vbrk-kunrg
                             CHANGING lw_vbrk-wapu
                                      lw_vbrk-form.

************Get Tax / VAT out
          PERFORM f_get_vat_out USING    lw_vbrk-vbeln
                                         lw_vbrk-posnr
                                CHANGING ld_tax
                                         ld_vatout.

************Get VAT in
          PERFORM f_get_vat_in USING    lw_vbrk-vbeln
                                        lw_vbrk-posnr
                               CHANGING ld_vatin.

************Check Internal use (VAT out = VAT in)
          IF ld_vatout = ld_vatin. " OR
*             lw_vbrk-bemot IN r_bemot.
            lw_vbrk-internal = 'X'.
          ELSE.
            CLEAR lw_vbrk-internal.
          ENDIF.

*************Get Tax / VAT out
*          READ TABLE t_priceall WITH KEY vbeln = lw_vbrk-vbeln
*                                         posnr = lw_vbrk-posnr
*                                         ptype = ld_vatout
*                                         BINARY SEARCH.
*          IF sy-subrc = 0.
*            ld_tax = t_priceall-kbetr / d_taxfactor.
*            ld_vatout = t_priceall-kwert.
*          ENDIF.
*
*************Get VAT in
*          READ TABLE t_priceall WITH KEY vbeln = lw_vbrk-vbeln
*                                         posnr = lw_vbrk-posnr
*                                         ptype = ld_vatin
*                                         BINARY SEARCH.
*          IF sy-subrc = 0.
*            ld_vatin = t_priceall-kwert.
*          ELSE.
*            CLEAR ld_vatin.
*          ENDIF.

************Check Internal use (VAT out = VAT in)
*          IF ld_vatout = ld_vatin.
*            lw_vbrk-internal = 'X'.
*          ELSE.
*            CLEAR lw_vbrk-internal.
*          ENDIF.

************Get Amount

          PERFORM f_amounts USING lw_vbrk
                                  ld_tax
                            CHANGING lw_vbrk-itamt
                                     lw_vbrk-itdisc
                                     lw_vbrk-dpp
                                     lw_vbrk-ppn
                                     lw_vbrk-ppnbm
                                     lw_vbrk-xppnbm
                                     lw_vbrk-itoth
                                     lw_vbrk-itqty
                                     lw_vbrk-examt
                                     lw_vbrk-inamt
                                     lw_vbrk-itdiscex
                                     lw_vbrk-itdiscin
                                     lw_vbrk-stnk
****added by Rahmadi
*---Store PPH 22, PPH 23 amount
                                     lw_vbrk-pph22
                                     lw_vbrk-pph23.
****end of addition


************Update last updated amounts
          lw_vbrk-itamtlast = lw_vbrk-itamt.
          lw_vbrk-itdisclast = lw_vbrk-itdisc.
          lw_vbrk-dpplast = lw_vbrk-dpp.
          lw_vbrk-ppnlast = lw_vbrk-ppn.
          lw_vbrk-ppnbmlast = lw_vbrk-ppnbm.
          lw_vbrk-xppnbmlast = lw_vbrk-xppnbm.
          lw_vbrk-itothlast = lw_vbrk-itoth.
          lw_vbrk-itqtylast = lw_vbrk-itqty.
          lw_vbrk-examtlast = lw_vbrk-examt.
          lw_vbrk-inamtlast = lw_vbrk-inamt.
          lw_vbrk-itdiscexlast = lw_vbrk-itdiscex.
          lw_vbrk-itdiscinlast = lw_vbrk-itdiscin.
          lw_vbrk-stnklast = lw_vbrk-stnk.

************Process follow-up docs
          PERFORM f_followup_docs TABLES t_vbrkfo
                                  USING lw_vbrk
                                        ld_tax
                                  CHANGING lw_vbrk-itamtlast
                                           lw_vbrk-itdisclast
                                           lw_vbrk-dpplast
                                           lw_vbrk-ppnlast
                                           lw_vbrk-ppnbmlast
                                           lw_vbrk-xppnbmlast
                                           lw_vbrk-itothlast
                                           lw_vbrk-itqtylast
                                           lw_vbrk-examtlast
                                           lw_vbrk-inamtlast
                                           lw_vbrk-itdiscexlast
                                           lw_vbrk-itdiscinlast
                                           lw_vbrk-stnklast
****added by Rahmadi
*---Store PPH 22, PPH 23 amount
                                           lw_vbrk-pph22
                                           lw_vbrk-pph23.
****end of addition

************Get TARIF
          lw_vbrk-tarifxpbm = ( lw_vbrk-ppnbmlast / lw_vbrk-dpplast )
                                * 100.

*****removed by Rahmadi
*---not relevant
*************Get KAROSERI
*          PERFORM f_get_karoseri_itemdiv USING lw_vbrk-matnr
*                                         CHANGING lw_vbrk-karoseri
*                                                  lw_vbrk-itemdiv.
*****end of removal

************Get EQUIPMENT
          PERFORM f_get_equi USING lw_vbrk-ean11
                             CHANGING lw_vbrk-th_buat
                                      lw_vbrk-mesin.

************Get FAKTUR DATE
*          { Changed on 30 May 2002 - Delete p_fakdat
*          lw_vbrk-fakdat = fu_fakdat.

************Get MASATX
*          lw_vbrk-masatx = fu_fakdat+0(6).
*          lw_vbrk-gjahr = fu_fakdat+0(4).
          lw_vbrk-masatx = lw_vbrk-fakdat(6).
          lw_vbrk-yeartx = lw_vbrk-fakdat(4).
          lw_vbrk-gjahr = lw_vbrk-fakdat(4).

*          } Changed on 30 May 2002 - Delete p_fakdat

************Get ADDRESS

          IF lw_vbrk-internal = 'X'.
**************Internal use:
            lw_vbrk-name = d_pkpname.
            lw_vbrk-addrs1 = d_pkpaddrs1.
            lw_vbrk-addrs2 = d_pkpaddrs2.
            lw_vbrk-city = d_pkpcity.
            lw_vbrk-postal = d_pkppostal.
            lw_vbrk-stceg = d_pkpnpwp.
          ELSE.
            IF p_brnch = '8220' OR p_brnch = '8180' OR
              p_brnch = '8210'.
              lw_vbrk-name = p_brnch.
            ENDIF.
            PERFORM f_get_address USING    lw_vbrk-vbeln
                                  CHANGING lw_vbrk-name
                                           lw_vbrk-addrs1
                                           lw_vbrk-addrs2
                                           lw_vbrk-city
                                           lw_vbrk-postal
                                           lw_vbrk-kunnr
                                           lw_vbrk-stceg.

          ENDIF.

************Get WAPU
*          PERFORM f_get_wapu USING    lw_vbrk-kunrg
          PERFORM f_get_wapu USING    lw_vbrk-kunnr
                             CHANGING lw_vbrk-wapu
                                      lw_vbrk-form.

************Exclude if qty = 0 (after adjusted by the follow-ups)
          IF lw_vbrk-itqtylast LE 0 AND
             NOT lw_vbrk-fkart IN r_fkartp.   "added for MKM 09/02/2004
            MOVE-CORRESPONDING lw_vbrk TO lt_vbrkzero.
            APPEND lt_vbrkzero.
            CLEAR lw_vbrk.
          ELSE.
            MOVE-CORRESPONDING lw_vbrk TO t_vbrk.
            APPEND t_vbrk.

          ENDIF.
        ELSE.
          ld_flagerr = 'X'.
        ENDIF.
      ELSE.
        ld_flagerr = 'X'.
      ENDIF.
    ENDIF.

    AT END OF vbeln.
******Proceed ONLY billing with no erroneous item
      IF NOT ld_flagerr IS INITIAL.
        READ TABLE t_vbrk WITH KEY vbeln = lw_vbrk-vbeln.
        IF sy-subrc = 0.
          DELETE t_vbrk WHERE vbeln = lw_vbrk-vbeln.
        ENDIF.
      ENDIF.
      CLEAR ld_flagerr.
    ENDAT.
  ENDLOOP.

**Unlocking error billings
  IF NOT t_error[] IS INITIAL.
    lt_unlock[] = t_error[].
    SORT lt_unlock BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_unlock COMPARING vbeln.
    LOOP AT lt_unlock.
      PERFORM f_unlock_error_billing USING lt_unlock-vbeln.
    ENDLOOP.
    SORT t_error BY msg vbeln.
  ENDIF.

**Sorting tables
  IF NOT t_vbrk[] IS INITIAL.
    SORT t_vbrk BY vbeln posnr.
  ENDIF.

ENDFORM.                    " F_PROCESS_DATAS

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_NOTARETUR
*&---------------------------------------------------------------------*
FORM f_process_notaretur.

  IF tabstrip-activetab = 'SPLIT'.

    t_notareturdums[] = t_notaretur[].

  ELSE.
*----Only selected Records.
    LOOP AT t_notaretur.
      READ TABLE t_vbrkscr WITH KEY vbeln = t_notaretur-vbeln.
      IF sy-subrc = 0.
        IF t_vbrkscr-sel = space.
          DELETE t_notaretur.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDIF.

  IF NOT t_notaretur[] IS INITIAL.

    REFRESH: t_vbrk, t_vbrk1.

    CLEAR t_notaretur.
    READ TABLE t_notaretur INDEX 1.
    PERFORM f_get_header_data TABLES r_pstyv
                              USING  p_vkorg
                                     p_gsber
                                     p_spart
                                     p_brnch
                                     p_busln
                                     p_bukrs
                                     t_notaretur-fkdat.

    PERFORM f_collect_billing_infos TABLES s_fkdat
                                          s_stceg
                                   USING p_vkorg
                                         p_gsber
                                         p_spart
                                         p_brnch
                                         p_busln
                                         p_bukrs.

    PERFORM f_get_supporting_data USING p_vkorg
                                        p_gsber
                                        p_spart
                                        p_brnch
                                        p_busln.

    PERFORM f_process_datas USING p_vkorg
                                  p_gsber
                                  p_spart
                                  p_brnch
                                  p_busln
                                  p_bukrs.
*                                  p_fakdat.

    IF tabstrip-activetab = 'SPLIT'.
      PERFORM f_prepare_split.
    ELSE.
      PERFORM f_get_data_02_03.

      PERFORM f_save_to_table.

      PERFORM f_popup_list
            USING 'F_WRITE_NOTARETUR_LIST'
                    'List of Created Nota Retur'
                    60
                    5
                    20
                    15
                    'X'.

    ENDIF.

    SET SCREEN 0.
*    LEAVE SCREEN.
  ENDIF.
ENDFORM.                    " F_PROCESS_NOTARETUR

*---------------------------------------------------------------------*
*       FORM f_crtfakturpajak_getstddata                              *
*---------------------------------------------------------------------*
FORM f_crtfakturpajak_getstddata
     USING    fu_fakdat LIKE zgdtxdt0003-fakdat
     CHANGING fc_subrc LIKE sy-subrc.

  CLEAR fc_subrc.

  PERFORM f_collect_billing_info
          TABLES s_fkdat
                 s_stceg
          USING  p_vkorg
                 p_gsber
                 p_spart
                 p_brnch
                 p_busln
                 p_bukrs
                 space
                 space.

  PERFORM f_get_header_data
          TABLES r_pstyv
          USING  p_vkorg
                 p_gsber
                 p_spart
                 p_brnch
                 p_busln
                 p_bukrs
                 fu_fakdat.

  PERFORM f_get_supporting_data
          USING  p_vkorg
                 p_gsber
                 p_spart
                 p_brnch
                 p_busln.

  PERFORM f_crtfakturpajak_process_data
          USING    p_vkorg
                   p_gsber
                   p_spart
                   fu_fakdat
          CHANGING fc_subrc.

ENDFORM.                    "f_crtfakturpajak_getstddata


*---------------------------------------------------------------------*
*       FORM f_get_my_vat_out                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  fc_procent_ppn                                                *
*---------------------------------------------------------------------*
FORM f_get_my_vat_out
     CHANGING fc_procent_ppn.
  DATA: ld_tax    LIKE t_priceall-kbetr,
        ld_vatout LIKE t_priceall-kwert.
  CLEAR fc_procent_ppn.
  LOOP AT t_vbrk.
    PERFORM f_get_vat_out
            USING    t_vbrk-vbeln
                     t_vbrk-posnr
            CHANGING ld_tax
                     ld_vatout.
    IF NOT ld_tax IS INITIAL.
      EXIT.
    ENDIF.
  ENDLOOP.
  fc_procent_ppn = ld_tax * 100.
ENDFORM.                    "f_get_my_vat_out

*---------------------------------------------------------------------*
*       FORM f_crtfakturpajak_process_data                            *
*---------------------------------------------------------------------*
FORM f_crtfakturpajak_process_data
     USING    fu_vkorg
              fu_gsber
              fu_spart
              fu_fakdat
     CHANGING fc_subrc.

  CLEAR: fc_subrc.

  DATA: ld_tabixn   LIKE sy-tabix, ld_tabixp LIKE sy-tabix,
        ld_tabixc   LIKE sy-tabix, ld_tabixx LIKE sy-tabix,
        ld_subrcn   LIKE sy-subrc, ld_subrcp LIKE sy-subrc,
        ld_subrcc   LIKE sy-subrc, ld_subrcx LIKE sy-subrc,
        ld_flagerr,
        ld_cancel,
        ld_cbelnr   LIKE zgdtxdt0002-belnr,
        lw_vbrk     LIKE t_vbrk, ld_tax    LIKE konv-kbetr,
        ld_vatin    LIKE konv-kwert,
        ld_vatout   LIKE konv-kwert,
        lt_vbrkzero LIKE t_vbrk  OCCURS 1 WITH HEADER LINE,
        lt_unlock   LIKE t_error OCCURS 1 WITH HEADER LINE,
        lt_line     LIKE tline OCCURS 0,
        ld_sbc      LIKE sy-subrc,
        ld_tabix    LIKE sy-tabix.

  CHECK NOT t_vbrk1[] IS INITIAL.
  SORT t_vbrk1 BY vbeln posnr fkdat.

  CLEAR: t_vbrkc, t_tariff.
  REFRESH: t_vbrkc, t_tariff.

* GET Include-Exclude Indicator
* Assume user can only select one record to process at a time!
  READ TABLE t_vbrk1 INDEX 1.
  DATA: ld_zgdtxdt0002_exclude.
  IF sy-subrc = 0.
    READ TABLE t_vbfa
         WITH KEY vbeln   = t_vbrk1-vbeln
                  vbtyp_n = 'O'  "O=Credit Memo
                  vbtyp_v = 'M'. "M=Invoice
    IF sy-subrc = 0.
      SELECT SINGLE exclude
             FROM   zgdtxdt0002
             INTO   ld_zgdtxdt0002_exclude
             WHERE  vbeln = t_vbfa-vbelv.
***added by Rahmadi for Debit memo 16/07/2004
    ELSE.
      READ TABLE t_vbfa
           WITH KEY vbeln   = t_vbrk1-vbeln
                    vbtyp_n = 'P'  "P=Debit Memo
                    vbtyp_v = 'M'. "M=Invoice
      IF sy-subrc = 0.
        SELECT SINGLE exclude
               FROM   zgdtxdt0002
               INTO   ld_zgdtxdt0002_exclude
               WHERE  vbeln = t_vbfa-vbelv.
      ENDIF.
***end of addition
    ENDIF.
  ENDIF.

  LOOP AT t_vbrk1.
    ld_tabix = sy-tabix.
    MOVE-CORRESPONDING t_vbrk1 TO lw_vbrk.

    AT NEW vbeln.
      CLEAR:
        ld_flagerr,
        ld_cancel,
        t_tariff.
    ENDAT.

    IF ld_flagerr IS INITIAL.
      PERFORM f_check_acc_docs USING lw_vbrk " fu_vkorg
                                     'N'
                            CHANGING lw_vbrk-belnr
                                     ld_subrcn.
      IF ld_subrcn = 0.

****modified by Rahmadi
*---not relevant
*********Check KWITANSI -- Only for SERVICE (Error if no kwitansi)
*        IF lw_vbrk-spart = d_service.
**---------INTERNAL USE no need to check kwitansi (BEMOT = 11 to 19)
*          IF lw_vbrk-bemot IN r_bemot.
*            CLEAR ld_subrcn.
*            lw_vbrk-kwitansi = lw_vbrk-gsber.
*          ELSE.
*            PERFORM f_get_kwitansi USING lw_vbrk
*                                CHANGING lw_vbrk-kwitansi lw_vbrk-erdt2
*                                         ld_subrcn.
*            IF lw_vbrk-kwitansi IS INITIAL.
*              lw_vbrk-kwitansi = lw_vbrk-gsber.
*            ENDIF.
*          ENDIF.
*        ELSE.
*          CLEAR ld_subrcn.
*        ENDIF.
        CLEAR ld_subrcn.
****end of modification

        IF ld_subrcn = 0.
**********Check Cancel docs
          READ TABLE t_vbrkfc WITH KEY vbelv = lw_vbrk-vbeln
                                       posnv = lw_vbrk-posnr
                                       BINARY SEARCH.
          IF sy-subrc = 0.
            ld_tabixc = sy-tabix.
            PERFORM f_check_acc_docs USING  t_vbrkfc  "fu_vkorg
                                            'C'
                                   CHANGING ld_cbelnr ld_subrcc.
            IF ld_subrcc = 0.
              PERFORM f_cancel_billing USING lw_vbrk.
              ld_cancel = 'X'.
            ENDIF.
          ENDIF.

**********NO cancel docs
          IF ld_cancel IS INITIAL.
************Get EQUIPMENT
            PERFORM f_get_equi USING lw_vbrk-ean11
                            CHANGING lw_vbrk-th_buat lw_vbrk-mesin.

************Get FAKTUR DATE
            lw_vbrk-fakdat = fu_fakdat.

************Get MASATX
            lw_vbrk-masatx = fu_fakdat+0(6).
            lw_vbrk-yeartx = fu_fakdat+0(4).
            lw_vbrk-gjahr  = fu_fakdat+0(4).

************Get WAPU
            PERFORM f_get_wapu USING    lw_vbrk-kunrg
                               CHANGING lw_vbrk-wapu  lw_vbrk-form.

************Get Tax / VAT out
            PERFORM f_get_vat_out USING    lw_vbrk-vbeln lw_vbrk-posnr
                                  CHANGING ld_tax        ld_vatout.

************Get VAT in
            PERFORM f_get_vat_in USING    lw_vbrk-vbeln lw_vbrk-posnr
                                 CHANGING ld_vatin.

***********Check Internal use (VAT out = VAT in)
            IF ld_vatout = ld_vatin OR lw_vbrk-bemot IN r_bemot.
              lw_vbrk-internal = 'X'.
            ELSE.
              CLEAR lw_vbrk-internal.
            ENDIF.

************Get ADDRESS
            IF lw_vbrk-internal = 'X'.
*-------------Internal use:
              lw_vbrk-name   = d_pkpname.
              lw_vbrk-addrs1 = d_pkpaddrs1.
              lw_vbrk-addrs2 = d_pkpaddrs2.
              lw_vbrk-city   = d_pkpcity.
              lw_vbrk-postal = d_pkppostal.
              lw_vbrk-stceg  = d_pkpnpwp.
            ELSE.
*-------------get customer from text req justinus 30-05.2002
              PERFORM f_get_custtext TABLES lt_line
                                      USING lw_vbrk-kunrg
                                   CHANGING lw_vbrk-name  lw_vbrk-addrs1
                                            lw_vbrk-addrs2 lw_vbrk-city
                                            lw_vbrk-postal ld_sbc.
              IF ld_sbc NE 0.
                IF p_brnch = '8220' OR p_brnch = '8180' OR
                  p_brnch = '8210'.
                  lw_vbrk-name = p_brnch.
                ENDIF.
                PERFORM f_get_address USING lw_vbrk-vbeln
                                   CHANGING lw_vbrk-name  lw_vbrk-addrs1
                                            lw_vbrk-addrs2 lw_vbrk-city
                                            lw_vbrk-postal lw_vbrk-kunnr
                                            lw_vbrk-stceg.

              ENDIF.
            ENDIF.

************Get Amount
            PERFORM f_amounts USING    lw_vbrk
                                       ld_tax
                              CHANGING lw_vbrk-itamt    lw_vbrk-itdisc
                                       lw_vbrk-dpp      lw_vbrk-ppn
                                       lw_vbrk-ppnbm    lw_vbrk-xppnbm
                                       lw_vbrk-itoth    lw_vbrk-itqty
                                       lw_vbrk-examt    lw_vbrk-inamt
                                       lw_vbrk-itdiscex lw_vbrk-itdiscin
                                       lw_vbrk-stnk
****added by Rahmadi
*---Store PPH 22, PPH 23 amount
                                       lw_vbrk-pph22
                                       lw_vbrk-pph23.
****end of addition


************Update last updated amounts
            PERFORM f_crtfakturpajak_lastamount
                    USING    lw_vbrk-vbeln
                             lw_vbrk-posnr
                             lw_vbrk-itamt
                             lw_vbrk-examt
                             lw_vbrk-inamt
                             lw_vbrk-itdisc
                             lw_vbrk-itdiscex
                             lw_vbrk-itdiscin
                             lw_vbrk-ppn
                             lw_vbrk-itqty
                             ld_zgdtxdt0002_exclude
                    CHANGING lw_vbrk-itamtlast
                             lw_vbrk-examtlast
                             lw_vbrk-inamtlast
                             lw_vbrk-itdisclast
                             lw_vbrk-itdiscexlast
                             lw_vbrk-itdiscinlast
                             lw_vbrk-dpplast
                             lw_vbrk-ppnlast
                             lw_vbrk-itqtylast.
*            lw_vbrk-itamtlast    = lw_vbrk-itamt.
*            lw_vbrk-itdisclast   = lw_vbrk-itdisc.
*            lw_vbrk-dpplast      = lw_vbrk-dpp.
*            lw_vbrk-ppnlast      = lw_vbrk-ppn.
*            lw_vbrk-ppnbmlast    = lw_vbrk-ppnbm.
*            lw_vbrk-xppnbmlast   = lw_vbrk-xppnbm.
*            lw_vbrk-itothlast    = lw_vbrk-itoth.
*            lw_vbrk-itqtylast    = lw_vbrk-itqty.
*            lw_vbrk-examtlast    = lw_vbrk-examt.
*            lw_vbrk-inamtlast    = lw_vbrk-inamt.
*            lw_vbrk-itdiscexlast = lw_vbrk-itdiscex.
*            lw_vbrk-itdiscinlast = lw_vbrk-itdiscin.
*            lw_vbrk-stnklast     = lw_vbrk-stnk.


**-----------Process follow-up docs
*            PERFORM f_followup_docs   TABLES t_vbrkfo
*                                       USING lw_vbrk
*                                             ld_tax
*                                    CHANGING lw_vbrk-itamtlast
*                                             lw_vbrk-itdisclast
*                                             lw_vbrk-dpplast
*                                             lw_vbrk-ppnlast
*                                             lw_vbrk-ppnbmlast
*                                             lw_vbrk-xppnbmlast
*                                             lw_vbrk-itothlast
*                                             lw_vbrk-itqtylast
*                                             lw_vbrk-examtlast
*                                             lw_vbrk-inamtlast
*                                             lw_vbrk-itdiscexlast
*                                             lw_vbrk-itdiscinlast
*                                             lw_vbrk-stnklast.

*************Get PPNBM TARIF
**---------------------------------------------------------------------
**  PPNBM Tariff currently is only applicable for mkm FINISHED UNIT,
**  since KAROSERI TYPE, which is used to determine Tariff amount is
**  only available in mkm finished unit.
**----------------------------------------------------------------------
*            t_tariff-dpp   = t_tariff-dpp + lw_vbrk-dpplast.
*            t_tariff-ppnbm = t_tariff-ppnbm + lw_vbrk-ppnbmlast.


************Exclude if amount = 0 (after adjusted by the follow-ups)
            IF ( lw_vbrk-itamtlast LE 0 OR lw_vbrk-itqtylast EQ 0 ) AND
               lw_vbrk-itdisclast >= 0.
*              If Discount Negatif - it's mean that this price
*              adjustment billing have higher price than old billing
*              (original billing) -
*              Example Price adjument change discount from 20000 to
*              5000 :
*              * Old billing = 1.000.000 (price) - 20.000 (discount)
*                            = 980.000,
*              * Price adjustment billing:
*                            = 1.000.000 (price) - 5.000 (discount)
*                            = 995.000
*              So in this case.... itdisclast will equal to -15.000

              MOVE-CORRESPONDING lw_vbrk TO lt_vbrkzero.
              APPEND lt_vbrkzero.
              CONTINUE.
            ENDIF.

*----------- For zero ppn
            IF lw_vbrk-ppnlast LE 0.
              MOVE-CORRESPONDING lw_vbrk TO t_error.
              t_error-msg = 'This billing has no VAT value'.
              APPEND t_error.
              fc_subrc = '4'.
            ELSE.
              MOVE-CORRESPONDING lw_vbrk TO t_vbrk.
              APPEND t_vbrk.
*              MOVE-CORRESPONDING lw_vbrk TO t_vbrkscr.
*              COLLECT t_vbrkscr.
            ENDIF.

          ELSE.
            ld_flagerr = 'X'.
          ENDIF.
        ELSE.
          ld_flagerr = 'X'.
        ENDIF.
      ELSE.
        ld_flagerr = 'X'.
      ENDIF.
    ENDIF.

    AT END OF vbeln.
      READ TABLE t_vbrk WITH KEY vbeln = lw_vbrk-vbeln.
      IF t_vbrk-itamtlast = 0 AND t_vbrk-itdisclast >= 0.
        ld_flagerr = 'X'.
      ENDIF.

******Collect TARIFF TABLE
      IF t_tariff-dpp <> 0 AND
         t_tariff-ppnbm <> 0.
        t_tariff-tarifxpbm = ( t_tariff-ppnbm / t_tariff-dpp ) * 100.
        IF t_tariff-tarifxpbm <> 0.
          t_tariff-vbeln = lw_vbrk-vbeln.
          APPEND t_tariff.
        ELSE.
          CLEAR t_tariff.
        ENDIF.
      ELSE.
        CLEAR t_tariff.
      ENDIF.

*-----Adjust PPNBM in Follow-up docs for mkm finished unit
*-----(for TARIFF purpose)
      PERFORM f_tariff_followup TABLES t_vbrkf
                                USING  lw_vbrk.

******Proceed ONLY billing with no erroneous item
      IF NOT ld_flagerr IS INITIAL.
        READ TABLE t_vbrk WITH KEY vbeln = lw_vbrk-vbeln.
        IF sy-subrc = 0.
          DELETE t_vbrk WHERE vbeln = lw_vbrk-vbeln.
        ENDIF.
        READ TABLE t_vbrkf WITH KEY vbelv = lw_vbrk-vbeln.
        IF sy-subrc = 0.
          DELETE t_vbrkf WHERE vbelv = lw_vbrk-vbeln.
        ENDIF.
        READ TABLE t_vbrkscr WITH KEY vbeln = lw_vbrk-vbeln.
        IF sy-subrc = 0.
          DELETE t_vbrkscr WHERE vbeln = lw_vbrk-vbeln.
        ENDIF.
      ENDIF.
      CLEAR ld_flagerr.
    ENDAT.
  ENDLOOP.

**Check quantity zero -- Delete RETURN if ZERO
  IF NOT lt_vbrkzero[] IS INITIAL.
    fc_subrc = 4.
    LOOP AT lt_vbrkzero.
      MOVE-CORRESPONDING lt_vbrkzero TO t_error.
      CONCATENATE 'Material' lt_vbrkzero-matnr
                  'has been fully returned'
                  INTO t_error-msg
                  SEPARATED BY space.
      APPEND t_error.
    ENDLOOP.
  ENDIF.

**Unlocking error billings
  IF NOT t_error[] IS INITIAL.
    lt_unlock[] = t_error[].
    SORT lt_unlock BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_unlock COMPARING vbeln.
    LOOP AT lt_unlock.
      PERFORM f_unlock_error_billing USING lt_unlock-vbeln.
    ENDLOOP.
    SORT t_error BY msg vbeln.

  ENDIF.

**Sorting tables
  IF NOT t_vbrkscr[] IS INITIAL.
    SORT t_vbrkscr BY vbeln.
  ENDIF.
  IF NOT t_vbrk[] IS INITIAL.
    SORT t_vbrk BY vbeln posnr.
  ENDIF.
  IF NOT t_vbrkf[] IS INITIAL.
    SORT t_vbrkf BY vbelv posnv.
  ENDIF.
  IF NOT t_tariff[] IS INITIAL.
    SORT t_tariff BY vbeln.
  ENDIF.
ENDFORM.                    "f_crtfakturpajak_process_data

*---------------------------------------------------------------------*
*       FORM f_crtfakturpajak_process                                 *
*---------------------------------------------------------------------*
FORM f_crtfakturpajak_process.
  DATA:
    ld_tabix LIKE sy-tabix,
    lt_vbrk0 LIKE t_vbrk0 OCCURS 0 WITH HEADER LINE.

* 0. Initialization.
  lt_vbrk0[] = t_vbrk0[].
  CLEAR d_rpc.
  d_printx = 'X'.

* 1. Get selected Records.
  LOOP AT t_crtfakturpajak.
    ld_tabix = sy-tabix.
    READ TABLE t_vbrkscr WITH KEY vbeln = t_crtfakturpajak-vbeln.
    IF sy-subrc = 0.
      IF t_vbrkscr-sel = space.
        DELETE t_crtfakturpajak INDEX ld_tabix.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF NOT t_crtfakturpajak[] IS INITIAL.
*   2. Initialization.
    REFRESH: t_zgdtxdt0002,
             t_zgdtxdt0003.
    CLEAR  : t_zgdtxdt0002,
             t_zgdtxdt0003.

    t_vbrk0[] = t_crtfakturpajak[].

*   User can only select 1 item for now (temp)
    READ TABLE t_crtfakturpajak INDEX 1.
    DELETE t_vbrk0 WHERE vbeln <> t_crtfakturpajak-vbeln.

*   3. Get Tax Standard Data.
    DATA: ld_subrc LIKE sy-subrc.
    PERFORM f_crtfakturpajak_getstddata
            USING    t_crtfakturpajak-fkdat
            CHANGING ld_subrc.
    IF ld_subrc <> 0.
      EXIT.
    ENDIF.

*   4. Fill Table zGDTXdt0003 & zGDTXdt0002.
    SORT t_vbrk BY vbeln posnr.
    DATA:
      ld_fakturno    LIKE t_zgdtxdt0003-fakturno,
      ld_vbrk        LIKE t_crtfakturpajak,
      ld_zgdtxdt0003 LIKE t_zgdtxdt0003.

    LOOP AT t_vbrk.
      ld_vbrk = t_vbrk.
      AT NEW vbeln.
        CLEAR ld_zgdtxdt0003.
        ADD 1 TO ld_fakturno.
      ENDAT.

*     4a. Fill detail table zGDTXdt0002
      MOVE-CORRESPONDING ld_vbrk TO t_zgdtxdt0002.
      t_zgdtxdt0002-fakturno = ld_fakturno.
      t_zgdtxdt0002-gjahr    = ld_vbrk-fkdat(4).
      t_zgdtxdt0002-itcurr   = t_zgdtxdt0002-waers = ld_vbrk-waerk.
      t_zgdtxdt0002-fakturno = ld_fakturno.

      t_zgdtxdt0002-itamtlast  = ld_vbrk-itamtlast.
      t_zgdtxdt0002-itdisclast = ld_vbrk-itdisclast.
      t_zgdtxdt0002-itothlast  = ld_vbrk-itothlast.
      t_zgdtxdt0002-dpplast    = ld_vbrk-dpplast.
      t_zgdtxdt0002-ppnlast    = ld_vbrk-ppnlast.
      t_zgdtxdt0002-ppnbmlast  = ld_vbrk-ppnbmlast.
      t_zgdtxdt0002-xppnbmlast = ld_vbrk-xppnbmlast.

      APPEND t_zgdtxdt0002.

      ADD ld_vbrk-ppnlast TO ld_zgdtxdt0003-fakppn.

*     4b. Fill master table zGDTXdt0003
      AT END OF vbeln.
        MOVE-CORRESPONDING ld_vbrk TO t_zgdtxdt0003.
        t_zgdtxdt0003-faktur_type = c_faktur_type_satuan.
        t_zgdtxdt0003-fakdat      = ld_vbrk-fkdat.
        t_zgdtxdt0003-masatx      = t_zgdtxdt0003-fakdat(6).
        t_zgdtxdt0003-yeartx      = t_zgdtxdt0003-fakdat(4).
        t_zgdtxdt0003-npwp        = ld_vbrk-stceg.
        t_zgdtxdt0003-userid      = sy-uname.
        t_zgdtxdt0003-fakturno    = ld_fakturno.
        t_zgdtxdt0003-fakppn      = ld_vbrk-ppnlast.
        t_zgdtxdt0003-cetakke     = 1.
        APPEND t_zgdtxdt0003.
      ENDAT.
    ENDLOOP.

    IF NOT t_zgdtxdt0002[] IS INITIAL.
      s_9600_io_petugas1 = d_petugas.
      s_9600_io_petugas2 = d_petugas2.
      s_9600_io_petugas3 = d_name_kaadm.
      s_9600_io_petugas4 = d_name_kacab.

*     Get Signature
      CLEAR: d_display, d_save, d_cancel.
      CALL SCREEN 9600 STARTING AT 15 5
                       ENDING AT 110 10.
      IF d_cancel IS INITIAL.
        CASE 'X'.
          WHEN s_9600_rb_petugas1.
            d_aktif = d_aktif1.
          WHEN s_9600_rb_petugas2.
            d_aktif = d_aktif2.
          WHEN s_9600_rb_petugas3.
            d_aktif = d_aktif3.
          WHEN s_9600_rb_petugas4.
            d_aktif = d_aktif4.
        ENDCASE.

****added by Rahmadi
*---Invoice Consolidation option
        d_flag = p_flag.
****end of addition

***modified by Rahmadi 16/07/2004
        IF NOT d_save IS INITIAL.
          PERFORM f_commit_save.
        ENDIF.
***end of modification

        PERFORM f_prepare_satuan_form
                TABLES t_zgdtxdt0002
                       t_zgdtxdt0003
                 USING p_flag
                       p_cust.  "added for Tempo

***modified by Rahmadi 16/07/2004
        IF d_display IS INITIAL.    "Print FP
          PERFORM f_call_function
                  USING    ' '
                           ' '
                           ' '
                           p_mpage
                           p_dest
                           space
                           p_cust
                  CHANGING ld_subrc.
        ELSE.                       "Display only
****Print preview
          PERFORM f_screen_preview.
          CLEAR d_dynnr.
          LEAVE SCREEN.
        ENDIF.
***end of modification
      ENDIF.
    ENDIF.
    SET SCREEN 0.
  ENDIF.

  t_vbrk0[] = lt_vbrk0[].
  d_rpc = 'X'.
ENDFORM.                    "f_crtfakturpajak_process

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_TO_TABLE
*&---------------------------------------------------------------------*
FORM f_save_to_table.

  IF NOT t_zgdtxdt0002[] IS INITIAL.
    MODIFY zgdtxdt0002 FROM TABLE t_zgdtxdt0002.
    COMMIT WORK.
    IF sy-subrc <> 0.
      MESSAGE a510(zz) WITH 'ZGDTXdt0002'.
    ENDIF.
  ENDIF.

  IF NOT t_zgdtxdt0003[] IS INITIAL.
    DELETE zgdtxdt0003 FROM TABLE t_delete00003.
    MODIFY zgdtxdt0003 FROM TABLE t_zgdtxdt0003.
    COMMIT WORK.
    IF sy-subrc <> 0.
      MESSAGE a510(zz) WITH 'ZGDTXdt0003'.
    ENDIF.
  ENDIF.

  IF NOT t_zgdtxdt0006[] IS INITIAL.
    MODIFY zgdtxdt0006 FROM TABLE t_zgdtxdt0006.
    COMMIT WORK.
    IF sy-subrc <> 0.
      MESSAGE a510(zz) WITH 'ZGDTXdt0003'.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_SAVE_TO_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_02_03
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data_02_03.

  DATA:
    ft_temp00003 TYPE STANDARD TABLE OF zgdtxdt0003 WITH HEADER LINE.

  DATA: ld_noretur LIKE zgdtxdt0002-noretur,
        ld_subrc   LIKE sy-subrc,
        ld_fkdat   LIKE zgdtxdt0002-fkdat.

  LOOP AT t_vbrk.

    MOVE-CORRESPONDING t_vbrk TO t_zgdtxdt0002.
    t_zgdtxdt0002-item = t_vbrk-arktx.
    t_zgdtxdt0002-itcurr = t_zgdtxdt0002-waers = t_vbrk-waerk.
    t_zgdtxdt0002-userid = sy-uname.
    t_zgdtxdt0002-bilref = t_vbrk-vbelv.
    t_zgdtxdt0002-npwp = t_vbrk-stceg.

*************** Currency selain IDR
**    IF t_vbrk-waerk NE c_local_curr.
**      PERFORM f_get_tax_rate USING t_vbrk-waerk
**                                   t_vbrk-fkdat
**                                   c_local_curr.
**
**----------- Recondition Tax information then save the original
**----------- transactions amount into foreign currency field (F)
**      t_zgdtxdt0002-ppndate = d_tax_valid.
**      t_zgdtxdt0002-itamt_f = t_vbrk-examtlast. "Exclude Tax
**      t_zgdtxdt0002-itdisc_f = t_vbrk-itdiscexlast. " Exclude Tax
**      t_zgdtxdt0002-itoth_f = t_zgdtxdt0002-itothlast.
**      t_zgdtxdt0002-dpp_f = t_zgdtxdt0002-dpplast.
**      t_zgdtxdt0002-ppn_f = t_zgdtxdt0002-ppnlast.
**      t_zgdtxdt0002-ppnbm_f = t_zgdtxdt0002-ppnbmlast.
**      t_zgdtxdt0002-xppnbm_f = t_zgdtxdt0002-xppnbmlast.
**      IF d_tcode = c_tcode_satuan OR d_tcode = c_tcode_split.
**        t_zgdtxdt0002-ppn_f = t_zgdtxdt0002-ppnlast.
**        t_zgdtxdt0002-ppnbm_f = t_zgdtxdt0002-ppnbmlast.
**        t_zgdtxdt0002-xppnbm_f = t_zgdtxdt0002-xppnbmlast.
**      ENDIF.
**----------- Translate the billing transaction into local currency
***************Updated in Tempo:rate no need to multiplied by rate factor
**-------------if using BAPI function
**              d_rate_tax = d_rate_tax * d_ratefactor.
***************End of Tempo update
**      t_zgdtxdt0002-rate_tax = d_rate_tax / 100.
**      t_zgdtxdt0002-trcurr = t_vbrk-waerk.
**      t_zgdtxdt0002-waers = c_local_curr.
**      IF t_zgdtxdt0002-spart NE d_used.
**      ELSE.
**        t_zgdtxdt0002-ppn = ( 1 / 100 ) * t_zgdtxdt0002-dpp.
**        t_zgdtxdt0002-ppnlast = ( 1 / 100 ) * t_zgdtxdt0002-dpplast.
**        t_zgdtxdt0002-ppn2 = ( 1 / 100 ) * t_zgdtxdt0002-dpp.
**        t_zgdtxdt0002-ppn2last = ( 1 / 100 ) * t_zgdtxdt0002-dpplast.
**      ENDIF.
**
**      t_zgdtxdt0002-ppn = t_zgdtxdt0002-ppn * d_rate_tax / 100.
**      t_zgdtxdt0002-ppnlast = t_zgdtxdt0002-ppnlast * d_rate_tax / 100.
**      t_zgdtxdt0002-ppn2 = t_zgdtxdt0002-ppn * d_rate_tax / 100.
**      t_zgdtxdt0002-ppn2last = t_zgdtxdt0002-ppnlast * d_rate_tax / 100.
**      t_zgdtxdt0002-dpp = t_zgdtxdt0002-dpp * d_rate_tax / 100.
**      t_zgdtxdt0002-dpplast = t_zgdtxdt0002-dpplast * d_rate_tax / 100.
**--------- new command
**
**
**----------- Convert Amount,Disc PPNBM into local currency
**----------- This convertion base on Billing Rate / Normal Rate
***************Tempo: Use Tax rate ZTAX for the transaction - all pricing
**              d_rate_std = t_zgdtxdt0002-kurrf * d_ratefactor.
**      d_rate_std = d_rate_tax.
***************End of Tempo change
**      t_zgdtxdt0002-rate_std = d_rate_std / 100.
**      t_zgdtxdt0002-itdisc = t_zgdtxdt0002-itdisc * d_rate_std / 100.
**      t_zgdtxdt0002-itdisclast =
**      t_zgdtxdt0002-itdisclast * d_rate_std / 100.
**      t_zgdtxdt0002-itamt = t_zgdtxdt0002-itamt * d_rate_std / 100.
**      t_zgdtxdt0002-itamtlast =
**      t_zgdtxdt0002-itamtlast * d_rate_std / 100.
**      t_zgdtxdt0002-ppnbm = t_zgdtxdt0002-ppnbm * d_rate_std / 100.
**      t_zgdtxdt0002-ppnbmlast =
**      t_zgdtxdt0002-ppnbmlast * d_rate_std / 100.
**      t_zgdtxdt0002-xppnbm = t_zgdtxdt0002-xppnbm * d_rate_std / 100.
**      t_zgdtxdt0002-xppnbmlast =
**      t_zgdtxdt0002-xppnbmlast * d_rate_std / 100.
**------------ Tariff must be converted into local currency
**      t_tariff-dpp = t_tariff-dpp * d_rate_tax / 100.
**      t_tariff-ppnbm = t_tariff-ppnbm * d_rate_std / 100.
**    ELSE.
**      t_zgdtxdt0002-rate_tax = 1.
**      t_zgdtxdt0002-rate_std = 1.
**      t_zgdtxdt0002-trcurr = t_vbrk-waerk.
**------------ Eliminated rounding problem (Hard code)
**      IF t_zgdtxdt0002-spart NE d_used.
**        t_zgdtxdt0002-ppn2 = 10 / 100 * t_zgdtxdt0002-dpp.
**        t_zgdtxdt0002-ppn2last = 10 / 100 * t_zgdtxdt0002-dpplast.
**      ELSE.
**        t_zgdtxdt0002-ppn2 = ( 1 / 100 ) * t_zgdtxdt0002-dpp.
**        t_zgdtxdt0002-ppn2last = ( 1 / 100 ) * t_zgdtxdt0002-dpplast.
**      ENDIF.
**    ENDIF.
****************

    IF tabstrip-activetab = 'SPLIT'.
      ON CHANGE OF t_vbrk-fakturno.
        CLEAR: ld_noretur, ld_subrc.

***changed for Tempo
***Get nota retur number from selection screen if not blank
        IF p_noret IS INITIAL.
          d_objrange = d_noret_object.
          PERFORM f_get_next_numbers USING  d_objrange
                                  CHANGING ld_noretur
                                           ld_subrc.
          IF ld_subrc <> 0.
            MESSAGE a000(zz) WITH 'Please maintain number ranges'.
          ENDIF.
        ELSE.
          ld_noretur = p_noret.
        ENDIF.
***end of Tempo changes
      ENDON.
    ELSE.
      ON CHANGE OF t_vbrk-vbeln.
        CLEAR: ld_noretur, ld_subrc.
***changed for Tempo
***Get nota retur number from selection screen if not blank
        IF p_noret IS INITIAL.
          d_objrange = d_noret_object.
          PERFORM f_get_next_numbers USING  d_objrange
                                  CHANGING ld_noretur
                                           ld_subrc.
          IF ld_subrc <> 0.
            MESSAGE a000(zz) WITH 'Please maintain number ranges'.
          ENDIF.
        ELSE.
          ld_noretur = p_noret.
        ENDIF.
***end of Tempo changes
      ENDON.
    ENDIF.

    BREAK bcrmd.

    IF ( t_vbrk-fkart IN r_fkartr OR
         t_vbrk-fkart IN r_fkartc OR
         t_vbrk-fkart IN r_fkartp ).   "changed for MKM 09/02/2004
      t_zgdtxdt0002-noretur = ld_noretur.
      t_zgdtxdt0002-dtretur = t_zgdtxdt0002-fkdat.
      APPEND t_zgdtxdt0002.
    ENDIF.

    DATA: lt_zgdtxdt0003 LIKE zgdtxdt0003 OCCURS 0.

*    SELECT SINGLE * FROM zGDTXdt0003
*               WHERE fakturno = t_vbrk-fakturno.

    SELECT * INTO TABLE lt_zgdtxdt0003 FROM zgdtxdt0003
               WHERE fakturno = t_vbrk-fakturno.

    IF sy-subrc = 0.
      SORT lt_zgdtxdt0003 BY returcount DESCENDING.
      READ TABLE lt_zgdtxdt0003 INDEX 1 INTO zgdtxdt0003.

      MOVE-CORRESPONDING zgdtxdt0003 TO t_zgdtxdt0003.

      IF t_vbrk-fkart IN r_fkartp.
        MOVE-CORRESPONDING zgdtxdt0003 TO t_zgdtxdt0006.
        t_zgdtxdt0006-bukrs = zgdtxdt0003-bukrs.
        APPEND t_zgdtxdt0006.
      ENDIF.

      t_zgdtxdt0003-fakppn    = t_zgdtxdt0002-ppn.
      t_zgdtxdt0003-fakxppnbm = t_zgdtxdt0002-xppnbm.
      t_zgdtxdt0003-fakppnbm  = t_zgdtxdt0002-ppnbm.
      t_zgdtxdt0003-masatx    = t_vbrk-masatx.
      t_zgdtxdt0003-yeartx    = t_vbrk-yeartx.

****added by Rahmadi
*---Store DPP total, PPH 22, PPH 23
      t_zgdtxdt0003-fakdpp    = t_zgdtxdt0002-dpp.
      t_zgdtxdt0003-fakpph22 = t_zgdtxdt0002-pph22.
      t_zgdtxdt0003-fakpph23  = t_zgdtxdt0002-pph23.
****end of addition
      IF p_bukrs = '8220' OR p_bukrs = '8180' OR
        p_bukrs = '8210' OR p_bukrs = '8040'.
        ld_fkdat = t_zgdtxdt0003-fakdat.
      ELSE.
        t_zgdtxdt0003-fakdat = t_vbrk-fakdat.
      ENDIF.

      IF t_vbrk-fkart IN r_fkartr OR
         t_vbrk-fkart IN r_fkartc OR
         t_vbrk-fkart IN r_fkartp.   "changed for MKM 09/02/2004
        t_zgdtxdt0003-returcount = t_zgdtxdt0003-returcount + 1.
        COLLECT t_zgdtxdt0003.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF p_bukrs = '8220' OR p_bukrs = '8180' OR
    p_bukrs = '8210' OR p_bukrs = '8040'.
    LOOP AT t_zgdtxdt0002.
      t_zgdtxdt0002-fkdat = ld_fkdat.
      MODIFY t_zgdtxdt0002 TRANSPORTING fkdat.
    ENDLOOP.
    REFRESH: t_zgdtxdt0003.
  ENDIF.
ENDFORM.                    " F_GET_DATA_02_03

*&---------------------------------------------------------------------*
*&      Form  F_GET_NEXT_NUMBER
*&---------------------------------------------------------------------*
FORM f_get_next_numbers USING    fu_object
                       CHANGING fc_returno
                                fc_subrc.

  DATA lw_nriv LIKE nriv.
  DATA ld_nrlevel LIKE nriv-tonumber.
  DATA ld_fakturno LIKE nriv-nrlevel.
  DATA ld_fakno LIKE nriv-nrlevel.

**Get record with current number <> 0
  SELECT SINGLE * INTO lw_nriv
                  FROM nriv
                  WHERE object = fu_object
                    AND subobject = p_bukrs
                    AND nrlevel <> '0'.
  IF sy-subrc = 0.
****Current no must be <> Last no
    MOVE lw_nriv-nrlevel TO ld_nrlevel.
    IF ld_nrlevel = lw_nriv-tonumber.
******If last no has been reached, get NEW nrange id (curr no = '0')
      SELECT SINGLE * INTO lw_nriv
                      FROM nriv
                      WHERE object = fu_object
                        AND subobject = p_bukrs
                        AND nrlevel = '0'.
      IF sy-subrc <> 0.
        CLEAR fc_returno.
        fc_subrc = 2.
        EXIT.
      ENDIF.
    ENDIF.
  ELSE.
****Not found, get NEW nrange id (curr no = '0')
    SELECT SINGLE * INTO lw_nriv
                    FROM nriv
                    WHERE object = fu_object
                      AND subobject = p_bukrs
                      AND nrlevel = '0'.
    IF sy-subrc <> 0.
      CLEAR fc_returno.
      fc_subrc = 3.
      EXIT.
    ENDIF.
  ENDIF.

**Get next number in the range
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = lw_nriv-nrrangenr
      object                  = fu_object
      subobject               = lw_nriv-subobject
    IMPORTING
      number                  = ld_fakno
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      interval_overflow       = 6
      OTHERS                  = 7.
  IF sy-subrc <> 0.
    CLEAR fc_returno.
    fc_subrc = 3.
    EXIT.
  ENDIF.

  fc_returno = ld_fakno+8(12).
  IF p_bukrs = '8220' OR p_bukrs = '8180' OR
    p_bukrs = '8210'.
    fc_returno(2) = 'NR'.
  ENDIF.

* 0123
* 1234 567890123456
*       NR
ENDFORM.                    " F_GET_NEXT_NUMBER


*---------------------------------------------------------------------*
*       FORM F_WRITE_NOTARETUR_LIST                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_write_notaretur_list.
  DATA ld_intensified.
  WRITE : / 'Nota Retur Number Created = ' COLOR COL_HEADING.
  SORT t_zgdtxdt0002 BY noretur.
  LOOP AT t_zgdtxdt0002.
    ON CHANGE OF t_zgdtxdt0002-noretur.
      IF ld_intensified IS INITIAL.
        FORMAT INTENSIFIED ON.
        ld_intensified = 'X'.
      ELSE.
        FORMAT INTENSIFIED OFF.
        CLEAR ld_intensified.
      ENDIF.
      WRITE / t_zgdtxdt0002-noretur COLOR COL_NORMAL.
    ENDON.
  ENDLOOP.
ENDFORM.                    "f_write_notaretur_list


*---------------------------------------------------------------------*
*       FORM f_prepare_split                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_prepare_split.

*  PERFORM f_get_tax_standard_data.

*  PERFORM f_get_other_data.

**Get Material data
  PERFORM f_get_material_data TABLES t_vbrk.

  LOOP AT t_vbrk.
    READ TABLE t_notareturdummy INDEX 1.
    t_vbrk-faktur_type = t_notareturdummy-faktur_type.

****removed by Rahmadi
*---not relevant
*    PERFORM f_get_karoseri_itemdiv USING t_vbrk-matnr
*                                CHANGING t_vbrk-karoseri
*                                         t_vbrk-itemdiv.
****end of removal
    MODIFY t_vbrk.
  ENDLOOP.


  READ TABLE t_notareturdummy INDEX 1.
  IF sy-subrc = 0.
    CASE t_notareturdummy-faktur_type.
      WHEN 'A'.
        p_sp_qty = space.
        p_sp_amo = 'X'.
        p_sp_ite = space.
      WHEN 'Q'.
        p_sp_qty = 'X'.
        p_sp_amo = space.
        p_sp_ite = space.
      WHEN 'I'.
        p_sp_qty = space.
        p_sp_amo = space.
        p_sp_ite = 'X'.
    ENDCASE.
  ENDIF.

  IF p_sp_qty = 'X'.
    PERFORM f_prepare_data_screen.
    IF NOT s_9000_table[] IS INITIAL.
      CALL SCREEN 9000.
    ELSE.
      MESSAGE i000 WITH 'All Quantity Has Been Returned'.
    ENDIF.
  ELSEIF p_sp_amo = 'X'.
    PERFORM f_prepare_data_screen.
    CALL SCREEN 9100.
  ELSEIF p_sp_ite = 'X'.
*    CALL SCREEN 9200.
    PERFORM f_split_by_item.
  ENDIF.

  REFRESH t_notaretur[].
  t_notaretur[] = t_notareturdums[].

ENDFORM.                    "f_prepare_split






*----------------------------------------------------------------------*
*   Process SPLIT                                                      *
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  F_UCOMM_PREVIEW_SAVE_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0347   text
*      -->P_0348   text
*      -->P_0349   text
*----------------------------------------------------------------------*
FORM f_ucomm_preview_save_print
     USING fu_screen
           fu_preview
           fu_save.

* fu_preview = 'X'  -> Preview
* fu_preview = ' '  -> Print
* fu_preview = 'N'  -> doN't Print !

  DATA ld_subrc LIKE sy-subrc.
* 1. Prepare Data for Print
* 1a. Collect to table t_zGDTXdt0002 and t_zGDTXdt0003
  CASE fu_screen.
    WHEN '9000'.
      PERFORM f_9000_collect_table_tax
              TABLES   t_zgdtxdt0002
                       t_zgdtxdt0003
              CHANGING ld_subrc.

    WHEN '9100'.
      PERFORM f_9100_collect_table_tax
              TABLES   t_zgdtxdt0002
                       t_zgdtxdt0003
              CHANGING ld_subrc.
  ENDCASE.
  CHECK ld_subrc = 0.

****removed by Rahmadi
*---not relevant -- generalization changed to use ZGDTX0103 table
** 1b. Collect table t_zGDTXdt0002 ( for sparepart division only )
**     into only one item for one faktur pajak
*  CLEAR t_zGDTXdt0002.
*  READ TABLE t_zGDTXdt0002 INDEX 1.
*  IF t_zGDTXdt0002-spart = d_sparts OR
*     ( t_zGDTXdt0002-spart = d_service AND
*       t_zGDTXdt0002-pstyv = c_pstyv_parts ).
*    PERFORM f_collect_spart_tzGDTXdt0002
*            TABLES t_zGDTXdt0002.
*  ENDIF.
****end of removal

* 1c. Collect table t_vbrk which has amount 0 to table zGDTXdt0002 ,
*     with fakturno equal to first fakturno that zGDTXdt0002 had.
*     (because in above process, this record with amount 0 is not saved
*     yet)
  PERFORM f_collect_zero_amount
          TABLES t_zgdtxdt0002.


* 2. Collect to printing data zGDTXst0001 - zGDTXst0006
*    based on table t_zGDTXdt0002 and t_zGDTXdt0003
*  PERFORM f_prepare_split_to_display
*          TABLES   t_zGDTXdt0002  "Input
*                   t_zGDTXdt0003  "Input
*                   t_fpkp           "Output
*                   t_fcustomer      "Output
*                   t_fitem          "Output
*                   t_fsignature     "Output
*                   t_ftax           "Output
*          CHANGING ld_subrc.
*  CHECK ld_subrc = 0.

* 3. Save to table zGDTXdt0002 & zGDTXdt0003
  IF fu_save = 'X'.
*    DATA: ld_number_error LIKE zGDTXst0001-fakturno,
*          ld_msg(30).
*
*   3a. Checking first, is it okay to print?
*    PERFORM f_call_function_print_form
*            USING    'X'
*                     ' '
*                     'X'
*                     fu_screen
*            CHANGING ld_number_error.
*    IF NOT ld_number_error IS INITIAL.
*      CONCATENATE 'Error, page '
*                  ld_number_error
*                  'is more than one page'
*                  INTO ld_msg.
*      MESSAGE i000(zz) WITH ld_msg.
*      EXIT.
*    ENDIF.

*   3b. Get Amount for t_zGDTXdt0003
    PERFORM f_get_amount_txgdtxdt0003.

*   3c. Save
*    PERFORM f_commit_save.

    PERFORM f_save_to_table.

    PERFORM f_popup_list
        USING 'F_WRITE_NOTARETUR_LIST'
                'List of Created Nota Retur'
                60
                5
                20
                15
                'X'.


*   3d. Change dummy number to number range from commit save
*    PERFORM f_change_number_printing_table.
  ENDIF.

* 4. Print / Preview
*  IF fu_preview <>  'N'.
*    PERFORM f_9000_9100_9200_preview_print
*            USING fu_screen fu_preview.
*  ENDIF.

* 5. Message & Exit
  IF fu_save = 'X'.
*   PERFORM f_message_tax_number_created.
    LEAVE PROGRAM.
  ELSE.
    LEAVE TO SCREEN fu_screen.
  ENDIF.

ENDFORM.                    " F_UCOMM_PREVIEW_SAVE_PRINT


DEFINE m_9000_fill_item.
*  if s_9000_table-nqty&1 is initial.
*    continue.
*  endif.
  ft_zgdtxdt0002-itqtylast  = s_9000_table-nqty&1.
  ft_zgdtxdt0002-itamtlast  = s_9000_table-nqty&1 *
                                ld_itamtlast_satuan.
*  ft_zGDTXdt0002-itdisclast = s_9000_table-qty&1 *
*                                ld_itdisclast_satuan.
  ft_zgdtxdt0002-dpplast    = s_9000_table-nqty&1 * ld_dpplast_satuan.
*  ft_zGDTXdt0002-ppnlast    = s_9000_table-qty&1 * ld_ppnlast_satuan.
  ft_zgdtxdt0002-xppnbmlast = s_9000_table-nqty&1 *
                                ld_xppnbmlast_satuan.
END-OF-DEFINITION.


*---------------------------------------------------------------------*
*       FORM f_9000_collect_table_tax                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  ft_zGDTXdt0002                                              *
*  -->  ft_zGDTXdt0003                                              *
*  -->  fc_subrc                                                      *
*---------------------------------------------------------------------*
FORM f_9000_collect_table_tax
     TABLES   ft_zgdtxdt0002 STRUCTURE t_zgdtxdt0002
              ft_zgdtxdt0003 STRUCTURE t_zgdtxdt0003
     CHANGING fc_subrc.


  DATA: BEGIN OF lt_fakturno OCCURS 0,
          no LIKE zgdtxst0001-fakturno,
        END OF lt_fakturno.

  DATA: ld_fakturno_counter LIKE zgdtxdt0002-fakturno,
        ld_subrc            LIKE sy-subrc,
        ld_old_kode         LIKE s_9200_table-kode,
        ld_flag_nqty1       TYPE i,
        ld_flag_nqty2       TYPE i,
        ld_flag_nqty3       TYPE i.

  DATA: ld_noretur LIKE zgdtxdt0002-noretur.

* 1. Initialization
  REFRESH: ft_zgdtxdt0002,
           ft_zgdtxdt0003.
  CLEAR  : ft_zgdtxdt0002,
           ft_zgdtxdt0003,
           t_vbrk,
           fc_subrc.
  READ TABLE t_vbrk INDEX 1.

* 2. Get how many page will be printed (1-3) and get number range
  LOOP AT s_9000_table WHERE itamtlast > 0.
    IF NOT s_9000_table-nqty1 IS INITIAL.
      ld_flag_nqty1 = 1.
    ENDIF.
    IF NOT s_9000_table-nqty2 IS INITIAL.
      ld_flag_nqty2 = 1.
    ENDIF.
    IF NOT s_9000_table-nqty3 IS INITIAL.
      ld_flag_nqty3 = 1.
    ENDIF.
  ENDLOOP.



  ld_fakturno_counter = ld_flag_nqty1 + ld_flag_nqty2 + ld_flag_nqty3.

  DO ld_fakturno_counter TIMES.
    lt_fakturno-no = sy-index.
    APPEND lt_fakturno.
  ENDDO.

  CHECK NOT lt_fakturno[] IS INITIAL.

* 4. Building Detail Table ZGDTXdt0002
  DATA: ld_counter           TYPE i,
        ld_itamtlast_satuan  TYPE type_packed,
        ld_itdisclast_satuan TYPE type_packed,
        ld_dpplast_satuan    TYPE type_packed,
        ld_ppnlast_satuan    TYPE type_packed,
        ld_ppnbmlast_satuan  TYPE type_packed,
        ld_xppnbmlast_satuan TYPE type_packed,
        ld_tarifxpbm_satuan  TYPE type_packed,

        ld_itamtlast_total   LIKE t_vbrk-itamtlast,
        ld_dpplast_total     LIKE t_vbrk-dpplast,
        ld_ppnbmlast_total   LIKE t_vbrk-ppnbmlast,
        ld_xppnbmlast_total  LIKE t_vbrk-xppnbmlast.

  LOOP AT s_9000_table WHERE itamtlast > 0.
    CLEAR ld_counter.
*   4a. Count Price per Qty
    IF s_9300_cb_incl_tax IS INITIAL.
      ld_itamtlast_satuan  = s_9000_table-examtlast /
                                          s_9000_table-itqtylast.
*      ld_itdisclast_satuan = s_9000_table-itdiscex /
*                                          s_9000_table-itqtylast.
    ELSE.
      ld_itamtlast_satuan  = s_9000_table-inamtlast /
                                          s_9000_table-itqtylast.
*      ld_itdisclast_satuan = s_9000_table-itdiscin /
*                                          s_9000_table-itqtylast.
    ENDIF.
    ld_dpplast_satuan    = s_9000_table-dpplast    /
                                        s_9000_table-itqtylast.
*    ld_ppnlast_satuan    = s_9000_table-ppnlast    /
*                                        s_9000_table-itqtylast.
    ld_ppnbmlast_satuan  = s_9000_table-ppnbmlast  /
                                        s_9000_table-itqtylast.
    ld_xppnbmlast_satuan = s_9000_table-xppnbmlast /
                                        s_9000_table-itqtylast.
    ld_tarifxpbm_satuan  = s_9000_table-tarifxpbm /
                                        s_9000_table-itqtylast.

    CLEAR: ld_itamtlast_total,
           ld_dpplast_total,
           ld_ppnbmlast_total,
           ld_xppnbmlast_total.


    DATA: ld_check1(1), ld_check2(1), ld_check3(1).

    CLEAR: ld_check1, ld_check2, ld_check3.


*   4b. Split by Qty
    LOOP AT lt_fakturno.
      ADD 1 TO ld_counter.
      MOVE-CORRESPONDING s_9000_table TO ft_zgdtxdt0002.
      MOVE-CORRESPONDING t_vbrk TO ft_zgdtxdt0003.
      ft_zgdtxdt0002-itcurr   = ft_zgdtxdt0002-waers = t_vbrk-waerk.
      ft_zgdtxdt0002-bilref   = t_vbrk-vbelv.

      IF NOT s_9000_table-nqty1 IS INITIAL AND ld_check1 = space.
        m_9000_fill_item 1.
        ft_zgdtxdt0002-fakturno = s_9000_table-fak1.
        ft_zgdtxdt0003-fakturno = s_9000_table-fak1.
        ld_check1 = 'X'.
        ADD ft_zgdtxdt0002-itamtlast  TO ld_itamtlast_total.
        ADD ft_zgdtxdt0002-dpplast    TO ld_dpplast_total.
        ADD ft_zgdtxdt0002-ppnbmlast  TO ld_ppnbmlast_total.
        ADD ft_zgdtxdt0002-xppnbmlast TO ld_xppnbmlast_total.
        IF s_9300_cb_incl_tax IS INITIAL.
          ft_zgdtxdt0002-exclude = 'X'.
        ELSE.
          CLEAR ft_zgdtxdt0002-exclude.
        ENDIF.

****added by Rahmadi
*---When needed to create new Faktur pajak/nota retur, selected invoice
*---consolidation option in the selection screen will be used
        ft_zgdtxdt0002-fakgr = p_flag.
****end of addition

*------ Get Nota Retur Number.
        CLEAR: ld_subrc, ld_noretur.

***changed for Tempo
***Get nota retur number from selection screen if not blank
        IF p_noret IS INITIAL.
          d_objrange = d_noret_object.
          PERFORM f_get_next_numbers USING  d_objrange
                                  CHANGING ld_noretur
                                           ld_subrc.
          IF ld_subrc <> 0.
            MESSAGE a000(zz) WITH 'Please maintain number ranges'.
          ELSE.
            t_zgdtxdt0002-noretur = ld_noretur.
            t_zgdtxdt0002-dtretur = t_zgdtxdt0002-fkdat.
          ENDIF.
        ELSE.
          ld_noretur = p_noret.
          t_zgdtxdt0002-noretur = ld_noretur.
          t_zgdtxdt0002-dtretur = t_zgdtxdt0002-fkdat.
        ENDIF.
***end of Tempo changes
*-----------------------------.

        APPEND ft_zgdtxdt0002.

        ft_zgdtxdt0003-faktur_type = c_faktur_type_split_qty.
*        ft_zGDTXdt0003-fakdat   = p_fakdat.
        ft_zgdtxdt0003-fakdat   = t_vbrk-fakdat.
        ft_zgdtxdt0003-npwp   = t_vbrk-stceg.
        ft_zgdtxdt0003-userid = sy-uname.
        ft_zgdtxdt0003-masatx = ft_zgdtxdt0002-masatx.
        ft_zgdtxdt0003-yeartx = ft_zgdtxdt0002-yeartx.

****added by Rahmadi
*---When needed to create new Faktur pajak/nota retur, selected invoice
*---consolidation option in the selection screen will be used
        ft_zgdtxdt0003-fakgr = p_flag.
****end of addition

        APPEND ft_zgdtxdt0003.
        CLEAR lt_fakturno.
        CONTINUE.
      ENDIF.

      IF NOT s_9000_table-nqty2 IS INITIAL AND ld_check2 = space.
        m_9000_fill_item 2.
        ft_zgdtxdt0002-fakturno = s_9000_table-fak2.
        ft_zgdtxdt0003-fakturno = s_9000_table-fak2.
        ld_check2 = 'X'.
        ADD ft_zgdtxdt0002-itamtlast  TO ld_itamtlast_total.
        ADD ft_zgdtxdt0002-dpplast    TO ld_dpplast_total.
        ADD ft_zgdtxdt0002-ppnbmlast  TO ld_ppnbmlast_total.
        ADD ft_zgdtxdt0002-xppnbmlast TO ld_xppnbmlast_total.
        IF s_9300_cb_incl_tax IS INITIAL.
          ft_zgdtxdt0002-exclude = 'X'.
        ELSE.
          CLEAR ft_zgdtxdt0002-exclude.
        ENDIF.

****added by Rahmadi
*---When needed to create new Faktur pajak/nota retur, selected invoice
*---consolidation option in the selection screen will be used
        ft_zgdtxdt0002-fakgr = p_flag.
****end of addition

*------ Get Nota Retur Number.
        CLEAR: ld_subrc, ld_noretur.
***changed for Tempo
***Get nota retur number from selection screen if not blank
        IF p_noret IS INITIAL.
          d_objrange = d_noret_object.
          PERFORM f_get_next_numbers USING  d_objrange
                                  CHANGING ld_noretur
                                           ld_subrc.
          IF ld_subrc <> 0.
            MESSAGE a000(zz) WITH 'Please maintain number ranges'.
          ELSE.
            t_zgdtxdt0002-noretur = ld_noretur.
            t_zgdtxdt0002-dtretur = t_zgdtxdt0002-fkdat.
          ENDIF.
        ELSE.
          ld_noretur = p_noret.
          t_zgdtxdt0002-noretur = ld_noretur.
          t_zgdtxdt0002-dtretur = t_zgdtxdt0002-fkdat.
        ENDIF.
***end of Tempo changes
*-----------------------------.

        APPEND ft_zgdtxdt0002.

        ft_zgdtxdt0003-faktur_type = c_faktur_type_split_qty.

*        ft_zGDTXdt0003-fakdat   = p_fakdat.
        ft_zgdtxdt0003-fakdat   = t_vbrk-fakdat.

        ft_zgdtxdt0003-npwp   = t_vbrk-stceg.
        ft_zgdtxdt0003-userid = sy-uname.
        ft_zgdtxdt0003-masatx = ft_zgdtxdt0002-masatx.
        ft_zgdtxdt0003-yeartx = ft_zgdtxdt0002-yeartx.

****added by Rahmadi
*---When needed to create new Faktur pajak/nota retur, selected invoice
*---consolidation option in the selection screen will be used
        ft_zgdtxdt0003-fakgr = p_flag.
****end of addition

        APPEND ft_zgdtxdt0003.
        CLEAR lt_fakturno.
        CONTINUE.
      ENDIF.

      IF NOT s_9000_table-nqty3 IS INITIAL AND ld_check3 = space.
        ld_check3 = 'X'.
        m_9000_fill_item 3.
        ft_zgdtxdt0002-fakturno = s_9000_table-fak3.
        ft_zgdtxdt0003-fakturno = s_9000_table-fak3.
        ADD ft_zgdtxdt0002-itamtlast  TO ld_itamtlast_total.
        ADD ft_zgdtxdt0002-dpplast    TO ld_dpplast_total.
        ADD ft_zgdtxdt0002-ppnbmlast  TO ld_ppnbmlast_total.
        ADD ft_zgdtxdt0002-xppnbmlast TO ld_xppnbmlast_total.
        IF s_9300_cb_incl_tax IS INITIAL.
          ft_zgdtxdt0002-exclude = 'X'.
        ELSE.
          CLEAR ft_zgdtxdt0002-exclude.
        ENDIF.

****added by Rahmadi
*---When needed to create new Faktur pajak/nota retur, selected invoice
*---consolidation option in the selection screen will be used
        ft_zgdtxdt0002-fakgr = p_flag.
****end of addition

*------ Get Nota Retur Number.
        CLEAR: ld_subrc, ld_noretur.
***changed for Tempo
***Get nota retur number from selection screen if not blank
        IF p_noret IS INITIAL.
          d_objrange = d_noret_object.
          PERFORM f_get_next_numbers USING  d_objrange
                                  CHANGING ld_noretur
                                           ld_subrc.
          IF ld_subrc <> 0.
            MESSAGE a000(zz) WITH 'Please maintain number ranges'.
          ELSE.
            t_zgdtxdt0002-noretur = ld_noretur.
            t_zgdtxdt0002-dtretur = t_zgdtxdt0002-fkdat.
          ENDIF.
        ELSE.
          ld_noretur = p_noret.
          t_zgdtxdt0002-noretur = ld_noretur.
          t_zgdtxdt0002-dtretur = t_zgdtxdt0002-fkdat.
        ENDIF.
***end of Tempo changes
*-----------------------------.

        APPEND ft_zgdtxdt0002.

        ft_zgdtxdt0003-faktur_type = c_faktur_type_split_qty.
*        ft_zGDTXdt0003-fakdat   = p_fakdat.
        ft_zgdtxdt0003-fakdat   = t_vbrk-fakdat.

        ft_zgdtxdt0003-npwp   = t_vbrk-stceg.
        ft_zgdtxdt0003-userid = sy-uname.
        ft_zgdtxdt0003-masatx = ft_zgdtxdt0002-masatx.
        ft_zgdtxdt0003-yeartx = ft_zgdtxdt0002-yeartx.

****added by Rahmadi
*---When needed to create new Faktur pajak/nota retur, selected invoice
*---consolidation option in the selection screen will be used
        ft_zgdtxdt0003-fakgr = p_flag.
****end of addition

        APPEND ft_zgdtxdt0003.
        CLEAR lt_fakturno.
        CONTINUE.
      ENDIF.

    ENDLOOP.

*   4c. Fixing Cause of Decimal Rounding :
    DATA ld_tabix_t_zgdtxdt0002 LIKE sy-tabix.
    READ TABLE ft_zgdtxdt0002
         WITH KEY vbeln = s_9000_table-vbeln
                  posnr = s_9000_table-posnr.
    IF sy-subrc = 0.
      ld_tabix_t_zgdtxdt0002 = sy-tabix.

*     4c.1 fixing amount
      DATA: ld_difference_itamtlast LIKE t_vbrk-itamtlast,
            ld_itamtlast            LIKE t_vbrk-itamtlast.
      IF s_9300_cb_incl_tax IS INITIAL.
        ld_itamtlast = s_9000_table-examtlast.
      ELSE.
        ld_itamtlast = s_9000_table-inamtlast.
      ENDIF.

      IF ld_itamtlast_total <> ld_itamtlast.
        ld_difference_itamtlast = ld_itamtlast -
                                  ld_itamtlast_total.
        ADD ld_difference_itamtlast TO ft_zgdtxdt0002-itamtlast.
      ENDIF.

*     4c.2 fixing dpp
      DATA: ld_difference_dpplast LIKE t_vbrk-dpplast.
      IF ld_dpplast_total <> s_9000_table-dpplast.
        ld_difference_dpplast = s_9000_table-dpplast -
                                ld_dpplast_total.
        ADD ld_difference_dpplast TO ft_zgdtxdt0002-dpplast.
      ENDIF.

*     4c.3 fixing PPNBM
      DATA: ld_difference_ppnbmlast LIKE t_vbrk-ppnbmlast.
      IF ld_ppnbmlast_total <> s_9000_table-ppnbmlast.
        ld_difference_ppnbmlast = s_9000_table-ppnbmlast -
                                  ld_ppnbmlast_total.
        ADD ld_difference_ppnbmlast TO ft_zgdtxdt0002-ppnbmlast.
      ENDIF.

*     4c.4 fixing XPPNBM
      DATA: ld_difference_xppnbmlast LIKE t_vbrk-xppnbmlast.
      IF ld_xppnbmlast_total <> s_9000_table-xppnbmlast.
        ld_difference_xppnbmlast = s_9000_table-xppnbmlast -
                                  ld_xppnbmlast_total.
        ADD ld_difference_xppnbmlast TO ft_zgdtxdt0002-xppnbmlast.
      ENDIF.

*     4c.5 Modify table
      MODIFY ft_zgdtxdt0002 INDEX ld_tabix_t_zgdtxdt0002
             TRANSPORTING itamtlast dpplast ppnbmlast xppnbmlast.
    ENDIF.
  ENDLOOP.

* 4d. Count PPN and Fixing PPN Rounding
  DATA: ld_ppnlast_total      LIKE ft_zgdtxdt0002-ppnlast,
        ld_fakturno           LIKE ft_zgdtxdt0002-fakturno,
        ld_difference_ppnlast LIKE ft_zgdtxdt0002-ppnlast.
  READ TABLE lt_fakturno INDEX 1.
  ld_fakturno = lt_fakturno-no.

  LOOP AT s_9000_table.
    CLEAR ld_ppnlast_total.
*   4e.1 Count PPN
    LOOP AT ft_zgdtxdt0002 WHERE vbeln = s_9000_table-vbeln AND
                                   posnr = s_9000_table-posnr.
      ld_tabix_t_zgdtxdt0002 = sy-tabix.
      ft_zgdtxdt0002-ppnlast = ft_zgdtxdt0002-dpplast * 10
                                 / 100.
      ADD ft_zgdtxdt0002-ppnlast TO ld_ppnlast_total.
      MODIFY ft_zgdtxdt0002 INDEX ld_tabix_t_zgdtxdt0002.
    ENDLOOP.

*   4e.2 Fixing PPN Rounding
    IF ld_ppnlast_total <> s_9000_table-ppnlast.
      ld_difference_ppnlast = s_9000_table-ppnlast - ld_ppnlast_total.
      READ TABLE ft_zgdtxdt0002
           WITH KEY vbeln    = s_9000_table-vbeln
                    posnr    = s_9000_table-posnr
                    fakturno = ld_fakturno.
      IF sy-subrc = 0.
        ld_tabix_t_zgdtxdt0002 = sy-tabix.
        ADD ld_difference_ppnlast TO ft_zgdtxdt0002-ppnlast.

        MODIFY ft_zgdtxdt0002 INDEX ld_tabix_t_zgdtxdt0002
                                TRANSPORTING ppnlast.
      ENDIF.
    ENDIF.
  ENDLOOP.

* 5. Count Discount.
  LOOP AT ft_zgdtxdt0002.
    ld_tabix_t_zgdtxdt0002 = sy-tabix.
    IF s_9300_cb_incl_tax IS INITIAL.
      ft_zgdtxdt0002-itdisclast = ft_zgdtxdt0002-itamtlast -
                                    ft_zgdtxdt0002-dpplast.
    ELSE.
      ft_zgdtxdt0002-itdisclast = ft_zgdtxdt0002-itamtlast -
                                   ( ft_zgdtxdt0002-dpplast +
                                     ft_zgdtxdt0002-ppnlast ).
    ENDIF.
    MODIFY ft_zgdtxdt0002 INDEX ld_tabix_t_zgdtxdt0002.
  ENDLOOP.

* 6. Fill in table follow up document of billing into zGDTXdt0002.
  PERFORM f_save_followupdocument
          TABLES ft_zgdtxdt0002
          USING  s_9300_cb_incl_tax.

  SORT ft_zgdtxdt0002 BY vbeln posnr fakturno.
ENDFORM.                    "f_9000_collect_table_tax




**************************** Screen 9100 *****************************
*---------------------------------------------------------------------*
*       FORM f_9100_collect_table_tax                                 *
*-_-------------------------------------------------------------------*
FORM f_9100_collect_table_tax
     TABLES   ft_zgdtxdt0002 STRUCTURE t_zgdtxdt0002
              ft_zgdtxdt0003 STRUCTURE t_zgdtxdt0003
     CHANGING fc_subrc.
  DATA: BEGIN OF lt_fakturno OCCURS 0,
          no LIKE zgdtxst0001-fakturno,
        END OF lt_fakturno.
  DATA: ld_fakturno_counter LIKE zgdtxdt0002-fakturno,
        ld_subrc            LIKE sy-subrc,
        ld_old_kode         LIKE s_9200_table-kode,
        ld_tabix            LIKE sy-tabix.

  DATA: ld_noretur LIKE zgdtxdt0002-noretur.

* 1. Initialization
  REFRESH: ft_zgdtxdt0002,
           ft_zgdtxdt0003.
  CLEAR  : ft_zgdtxdt0002,
           ft_zgdtxdt0003,
           t_vbrk,
           fc_subrc.
  READ TABLE t_vbrk INDEX 1.

* 2. Get how many page will be printed (1-3) and get number range
  IF NOT s_9100_io_amtlast1 IS INITIAL.
    ADD 1 TO ld_fakturno_counter.
  ENDIF.
  IF NOT s_9100_io_amtlast2 IS INITIAL.
    ADD 1 TO ld_fakturno_counter.
  ENDIF.
  IF NOT s_9100_io_amtlast3 IS INITIAL.
    ADD 1 TO ld_fakturno_counter.
  ENDIF.

* Get dummy number just for printing
  DO ld_fakturno_counter TIMES.
    lt_fakturno-no = sy-index.
    APPEND lt_fakturno.
  ENDDO.

  CHECK NOT lt_fakturno[] IS INITIAL.

* 4. Building Detail Table ZGDTXdt0002
  CLEAR t_vbrk.
  READ TABLE t_vbrk INDEX 1.
  MOVE-CORRESPONDING t_vbrk TO ft_zgdtxdt0002.
  MOVE-CORRESPONDING t_vbrk TO ft_zgdtxdt0003.
  ft_zgdtxdt0002-gjahr    = t_vbrk-fkdat(4).
  ft_zgdtxdt0002-itcurr   = ft_zgdtxdt0002-waers = t_vbrk-waerk.
  IF s_9300_cb_incl_tax IS INITIAL.
    ft_zgdtxdt0002-exclude = 'X'.
  ELSE.
    CLEAR ft_zgdtxdt0002-exclude.
  ENDIF.


  DATA: ld_check1(1), ld_check2(1), ld_check3(1).

  CLEAR: ld_check1, ld_check2, ld_check3.

  DATA: ld_ppn_procent TYPE i VALUE 10.

  LOOP AT lt_fakturno.

    IF NOT s_9100_io_namtlast1 IS INITIAL AND ld_check1 = space.

      ft_zgdtxdt0002-fakturno = d_faks1.
      ft_zgdtxdt0003-fakturno = d_faks1.
      ft_zgdtxdt0002-itamtlast  = s_9100_io_namtlast1.
      ft_zgdtxdt0002-itdisclast  = s_9100_io_ndisc1.

      IF t_vbrk-waerk = 'IDR'.
        ft_zgdtxdt0002-itamtlast  = ft_zgdtxdt0002-itamtlast / 100.
        ft_zgdtxdt0002-itdisclast = ft_zgdtxdt0002-itdisclast / 100.
      ENDIF.

*  Fill DPP & PPN
      ft_zgdtxdt0002-dpplast = ft_zgdtxdt0002-itamtlast -
                                 ft_zgdtxdt0002-itdisclast.
      ft_zgdtxdt0002-ppnlast = ( ft_zgdtxdt0002-dpplast *
                                   ld_ppn_procent ) / 100.

      ld_check1 = 'X'.

*------ Get Nota Retur Number.
      CLEAR: ld_subrc, ld_noretur.
      d_objrange = d_noret_object.
      PERFORM f_get_next_numbers USING  d_objrange
                              CHANGING ld_noretur
                                       ld_subrc.
      IF ld_subrc <> 0.
        MESSAGE a000(zz) WITH 'Please maintain number ranges'.
      ELSE.
        t_zgdtxdt0002-noretur = ld_noretur.
        t_zgdtxdt0002-dtretur = t_zgdtxdt0002-fkdat.
      ENDIF.
*-----------------------------.

      APPEND ft_zgdtxdt0002.

      ft_zgdtxdt0003-faktur_type = c_faktur_type_split_qty.
*     { Changed on 30 May 2002 - Delete p_fakdat
*     ft_zGDTXdt0003-fakdat   = p_fakdat.
      ft_zgdtxdt0003-fakdat   = t_vbrk-fakdat.
*     } Changed on 30 May 2002 - Delete p_fakdat

      ft_zgdtxdt0003-npwp   = t_vbrk-stceg.
      ft_zgdtxdt0003-userid = sy-uname.
      ft_zgdtxdt0003-masatx = ft_zgdtxdt0002-masatx.
      ft_zgdtxdt0003-yeartx = ft_zgdtxdt0002-yeartx.
      APPEND ft_zgdtxdt0003.
      CLEAR lt_fakturno.
      CONTINUE.
    ENDIF.


    IF NOT s_9100_io_namtlast2 IS INITIAL AND ld_check2 = space.

      ft_zgdtxdt0002-fakturno = d_faks2.
      ft_zgdtxdt0003-fakturno = d_faks2.
      ft_zgdtxdt0002-itamtlast  = s_9100_io_namtlast2.
      ft_zgdtxdt0002-itdisclast  = s_9100_io_ndisc2.

      IF t_vbrk-waerk = 'IDR'.
        ft_zgdtxdt0002-itamtlast  = ft_zgdtxdt0002-itamtlast / 100.
        ft_zgdtxdt0002-itdisclast = ft_zgdtxdt0002-itdisclast / 100.
      ENDIF.

*  Fill DPP & PPN
      ft_zgdtxdt0002-dpplast = ft_zgdtxdt0002-itamtlast -
                                 ft_zgdtxdt0002-itdisclast.
      ft_zgdtxdt0002-ppnlast = ( ft_zgdtxdt0002-dpplast *
                                   ld_ppn_procent ) / 100.

      ld_check2 = 'X'.
*------ Get Nota Retur Number.
      CLEAR: ld_subrc, ld_noretur.
***changed for Tempo
***Get nota retur number from selection screen if not blank
      IF p_noret IS INITIAL.
        d_objrange = d_noret_object.
        PERFORM f_get_next_numbers USING  d_objrange
                                CHANGING ld_noretur
                                         ld_subrc.
        IF ld_subrc <> 0.
          MESSAGE a000(zz) WITH 'Please maintain number ranges'.
        ELSE.
          t_zgdtxdt0002-noretur = ld_noretur.
          t_zgdtxdt0002-dtretur = t_zgdtxdt0002-fkdat.
        ENDIF.
      ELSE.
        ld_noretur = p_noret.
        t_zgdtxdt0002-noretur = ld_noretur.
        t_zgdtxdt0002-dtretur = t_zgdtxdt0002-fkdat.
      ENDIF.
***end of Tempo changes
*-----------------------------.

      APPEND ft_zgdtxdt0002.

      ft_zgdtxdt0003-faktur_type = c_faktur_type_split_qty.
*     { Changed on 30 May 2002 - Delete p_fakdat
*     ft_zGDTXdt0003-fakdat   = p_fakdat.
      ft_zgdtxdt0003-fakdat   = t_vbrk-fakdat.
*     } Changed on 30 May 2002 - Delete p_fakdat
      ft_zgdtxdt0003-npwp   = t_vbrk-stceg.
      ft_zgdtxdt0003-userid = sy-uname.
      ft_zgdtxdt0003-masatx = ft_zgdtxdt0002-masatx.
      ft_zgdtxdt0003-yeartx = ft_zgdtxdt0002-yeartx.
      APPEND ft_zgdtxdt0003.
      CLEAR lt_fakturno.
      CONTINUE.
    ENDIF.


    IF NOT s_9100_io_namtlast3 IS INITIAL AND ld_check3 = space.

      ft_zgdtxdt0002-fakturno = d_faks3.
      ft_zgdtxdt0003-fakturno = d_faks3.
      ft_zgdtxdt0002-itamtlast  = s_9100_io_namtlast3.
      ft_zgdtxdt0002-itdisclast  = s_9100_io_ndisc3.

      IF t_vbrk-waerk = 'IDR'.
        ft_zgdtxdt0002-itamtlast  = ft_zgdtxdt0002-itamtlast / 100.
        ft_zgdtxdt0002-itdisclast = ft_zgdtxdt0002-itdisclast / 100.
      ENDIF.

*  Fill DPP & PPN
      ft_zgdtxdt0002-dpplast = ft_zgdtxdt0002-itamtlast -
                                 ft_zgdtxdt0002-itdisclast.
      ft_zgdtxdt0002-ppnlast = ( ft_zgdtxdt0002-dpplast *
                                   ld_ppn_procent ) / 100.

      ld_check3 = 'X'.

*------ Get Nota Retur Number.
      CLEAR: ld_subrc, ld_noretur.
***changed for Tempo
***Get nota retur number from selection screen if not blank
      IF p_noret IS INITIAL.
        d_objrange = d_noret_object.
        PERFORM f_get_next_numbers USING  d_objrange
                                CHANGING ld_noretur
                                         ld_subrc.
        IF ld_subrc <> 0.
          MESSAGE a000(zz) WITH 'Please maintain number ranges'.
        ELSE.
          t_zgdtxdt0002-noretur = ld_noretur.
          t_zgdtxdt0002-dtretur = t_zgdtxdt0002-fkdat.
        ENDIF.
      ELSE.
        ld_noretur = p_noret.
        t_zgdtxdt0002-noretur = ld_noretur.
        t_zgdtxdt0002-dtretur = t_zgdtxdt0002-fkdat.
      ENDIF.
***end of Tempo changes
*-----------------------------.

      APPEND ft_zgdtxdt0002.

      ft_zgdtxdt0003-faktur_type = c_faktur_type_split_qty.
*     { Changed on 30 May 2002 - Delete p_fakdat
*     ft_zGDTXdt0003-fakdat   = p_fakdat.
      ft_zgdtxdt0003-fakdat   = t_vbrk-fakdat.
*     } Changed on 30 May 2002 - Delete p_fakdat
      ft_zgdtxdt0003-npwp   = t_vbrk-stceg.
      ft_zgdtxdt0003-userid = sy-uname.
      ft_zgdtxdt0003-masatx = ft_zgdtxdt0002-masatx.
      ft_zgdtxdt0003-yeartx = ft_zgdtxdt0002-yeartx.
      APPEND ft_zgdtxdt0003.
      CLEAR lt_fakturno.
      CONTINUE.
    ENDIF.

  ENDLOOP.

* 4a. Counting Total for tarif, PPNBM and xppnbm.
  DATA: ld_vbrk        LIKE t_vbrk,
        lt_zgdtxst0006 TYPE STANDARD TABLE OF zgdtxst0006
             WITH HEADER LINE.
  LOOP AT t_vbrk.
    ADD t_vbrk-xppnbmlast TO ld_vbrk-xppnbmlast.
    CLEAR lt_zgdtxst0006.
    lt_zgdtxst0006-tarifxpbm = t_vbrk-tarifxpbm.
    lt_zgdtxst0006-dpplast   = t_vbrk-dpplast.
    lt_zgdtxst0006-fakppnbm  = t_vbrk-ppnbmlast.
    COLLECT lt_zgdtxst0006.
  ENDLOOP.

* There will be only one tarif ppnbm for 1 billing, because :
* a. For KTB Unit, 1 billing consist of many units,
*    but there is no ppnbm exist.
* b. For mkm Unit, mkm Unit, etc..., 1 billing consist of
*    1 unit only, so there will be only 1 tarif ppnbm
* c. For Sparepart & Service, there will be no tarif ppnbm !
  DELETE lt_zgdtxst0006 WHERE tarifxpbm IS INITIAL.
  READ TABLE lt_zgdtxst0006 INDEX 1.
  IF sy-subrc = 0.
    ft_zgdtxdt0002-tarifxpbm  = lt_zgdtxst0006-tarifxpbm.
    ft_zgdtxdt0002-dpplast    = lt_zgdtxst0006-dpplast.
    ft_zgdtxdt0002-ppnbmlast  = lt_zgdtxst0006-fakppnbm.
    ft_zgdtxdt0002-xppnbmlast = ld_vbrk-xppnbmlast.
    MODIFY ft_zgdtxdt0002 INDEX 1
           TRANSPORTING tarifxpbm dpplast ppnbmlast xppnbmlast.
  ENDIF.

****removed by Rahmadi
*---logic is not relevant & not generic
*  CLEAR t_vbrk.
*  READ TABLE t_vbrk INDEX 1.
*
** 4c. Build Matnr, Desc and Qty
*  CLEAR ft_zGDTXdt0002.
*
*  CASE t_vbrk-spart.
*    WHEN d_fin_unit OR d_used.
*      CASE t_vbrk-vkorg.
*        WHEN c_vkorg_mkm.
*          READ TABLE t_vbrk WITH KEY karoseri = d_karu.
*          IF sy-subrc = 0.
*            ft_zGDTXdt0002-matnr     = t_vbrk-matnr.
*            ft_zGDTXdt0002-item      = t_vbrk-arktx.
*            ft_zGDTXdt0002-itqtylast = t_vbrk-itqtylast.
*          ENDIF.
*        WHEN c_vkorg_ktb.
*          LOOP AT t_vbrk.
*            ADD t_vbrk-itqtylast TO ft_zGDTXdt0002-itqtylast.
*          ENDLOOP.
*          ft_zGDTXdt0002-item = 'Kendaraan KTB'.
*      ENDCASE.
*
*    WHEN d_service.
*      CASE t_vbrk-itemdiv.
*        WHEN d_service.
*          ft_zGDTXdt0002-item = 'Service Jasa'.
*        WHEN d_sparts.
*          ft_zGDTXdt0002-item = c_split_sparepart.
*      ENDCASE.
*
*    WHEN d_sparts.
*      ft_zGDTXdt0002-item = c_split_sparepart.
*  ENDCASE.
*
*  MODIFY ft_zGDTXdt0002 TRANSPORTING matnr item itqtylast
*         WHERE NOT fakturno IS initial.
****end of removal

* 5. Fill in table follow up document of billing into zGDTXdt0002.
  PERFORM f_save_followupdocument
          TABLES ft_zgdtxdt0002
          USING  s_9300_cb_incl_tax.

  SORT ft_zgdtxdt0002 BY vbeln posnr fakturno.
ENDFORM.                    "f_9100_collect_table_tax


*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_NUMBER_PRINTING_TABLE
*&---------------------------------------------------------------------*
FORM f_change_number_printing_table.
  DATA: ld_tabix    LIKE sy-tabix,
        ld_fakturno LIKE t_zgdtxdt0003-fakturno.
  LOOP AT t_zgdtxdt0003.
    ld_tabix = sy-tabix.
    READ TABLE t_fpkp INDEX ld_tabix.
    IF sy-subrc = 0.
      ld_fakturno = t_fpkp-fakturno.
      t_fpkp-fakturno = t_zgdtxdt0003-fakturno.
      MODIFY t_fpkp TRANSPORTING fakturno
             WHERE fakturno = ld_fakturno.
      t_fcustomer-fakturno = t_zgdtxdt0003-fakturno.
      MODIFY t_fcustomer TRANSPORTING fakturno
             WHERE fakturno = ld_fakturno.
      t_fitem-fakturno = t_zgdtxdt0003-fakturno.
      MODIFY t_fitem TRANSPORTING fakturno
             WHERE fakturno = ld_fakturno.
      t_fsignature-fakturno = t_zgdtxdt0003-fakturno.
      MODIFY t_fsignature TRANSPORTING fakturno
             WHERE fakturno = ld_fakturno.
      t_ftax-fakturno = t_zgdtxdt0003-fakturno.
      MODIFY t_ftax TRANSPORTING fakturno
             WHERE fakturno = ld_fakturno.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CHANGE_NUMBER_dt0002_000003


*---------------------------------------------------------------------*
*       FORM f_collect_spart_tzGDTXdt0002                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  ft_zGDTXdt0002                                              *
*---------------------------------------------------------------------*
FORM f_collect_spart_tzgdtxdt0002
     TABLES ft_zgdtxdt0002 STRUCTURE t_zgdtxdt0002.

  DATA lt_zgdtxdt0002 LIKE t_zgdtxdt0002 OCCURS 0 WITH HEADER LINE.

* Change zGDTXdt0002 so it only save one record for one faktur pajak
* for sparepart
  LOOP AT ft_zgdtxdt0002.
    lt_zgdtxdt0002 = ft_zgdtxdt0002.
    CLEAR: lt_zgdtxdt0002-posnr,
           lt_zgdtxdt0002-matnr,
           lt_zgdtxdt0002-itemdiv,
           lt_zgdtxdt0002-rangka,
           lt_zgdtxdt0002-mesin,
           lt_zgdtxdt0002-th_buat,
           lt_zgdtxdt0002-rectype.
    lt_zgdtxdt0002-item = c_split_sparepart.
    COLLECT lt_zgdtxdt0002.
  ENDLOOP.

  ft_zgdtxdt0002[] = lt_zgdtxdt0002[].
ENDFORM.                    " F_COLLECT_SPART_TZGDTXdt0002


*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_ZERO_AMOUNT
*&---------------------------------------------------------------------*
FORM f_collect_zero_amount
     TABLES ft_zgdtxdt0002 STRUCTURE t_zgdtxdt0002.
  DATA ld_fakturno LIKE t_zgdtxdt0003-fakturno.
  READ TABLE t_zgdtxdt0003 INDEX 1.
  IF sy-subrc = 0.
    ld_fakturno = t_zgdtxdt0003-fakturno.
  ELSE.
    ld_fakturno = 1.
  ENDIF.
  LOOP AT t_vbrk WHERE ppnlast IS INITIAL.
    MOVE-CORRESPONDING t_vbrk TO t_zgdtxdt0002.
    t_zgdtxdt0002-fakturno = ld_fakturno.
    APPEND t_zgdtxdt0002.
  ENDLOOP.
ENDFORM.                    " F_COLLECT_ZERO_AMOUNT

*&---------------------------------------------------------------------*
*&      Form  F_GET_AMOUNT_TXGDTXdt0003
*&---------------------------------------------------------------------*
FORM f_get_amount_txgdtxdt0003.
  DATA ld_tabix LIKE sy-tabix.
  DATA ld_max_return LIKE t_zgdtxdt0003-returcount.

  LOOP AT t_zgdtxdt0003.
    ld_tabix = sy-tabix.
    CLEAR: t_zgdtxdt0003-fakppn,
           t_zgdtxdt0003-fakppnbm,
           t_zgdtxdt0003-fakxppnbm.
    READ TABLE t_zgdtxdt0002
               WITH KEY fakturno = t_zgdtxdt0003-fakturno.
    IF sy-subrc = 0.
      ADD t_zgdtxdt0002-ppnlast    TO t_zgdtxdt0003-fakppn.
      ADD t_zgdtxdt0002-ppnbmlast  TO t_zgdtxdt0003-fakppnbm.
      ADD t_zgdtxdt0002-xppnbmlast TO t_zgdtxdt0003-fakxppnbm.

      CLEAR ld_max_return.
      SELECT MAX( returcount )
             INTO ld_max_return
             FROM zgdtxdt0003
             WHERE fakturno = t_zgdtxdt0003-fakturno.
      IF sy-subrc = 0.
        t_zgdtxdt0003-returcount = ld_max_return.
      ENDIF.

      t_zgdtxdt0003-returcount = t_zgdtxdt0003-returcount + 1.
      MODIFY t_zgdtxdt0003 INDEX ld_tabix
             TRANSPORTING fakppn fakppnbm fakxppnbm returcount.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_GET_AMOUNT_TXGDTXdt0003

*---------------------------------------------------------------------*
*       FORM f_save_followupdocument                                  *
*---------------------------------------------------------------------*
FORM f_save_followupdocument
     TABLES ft_zgdtxdt0002 STRUCTURE t_zgdtxdt0002
     USING  fu_flag_include_tax.
  DATA: ld_vbeln    LIKE ft_zgdtxdt0002-vbeln,
        ld_fakturno LIKE ft_zgdtxdt0002-fakturno.

* Get first fakturno
  CLEAR ft_zgdtxdt0002.
  LOOP AT ft_zgdtxdt0002 WHERE NOT fakturno IS INITIAL.
    EXIT.
  ENDLOOP.
  ld_vbeln    = ft_zgdtxdt0002-vbeln.
  ld_fakturno = ft_zgdtxdt0002-fakturno.

  LOOP AT t_vbrkf WHERE vbelv = ld_vbeln.
    MOVE-CORRESPONDING t_vbrkf TO ft_zgdtxdt0002.
    ft_zgdtxdt0002-fakturno = ld_fakturno.
    IF fu_flag_include_tax = 'X'.
      ft_zgdtxdt0002-itamtlast  = t_vbrkf-inamtlast.
      ft_zgdtxdt0002-itdisclast = t_vbrkf-itdiscinlast.
    ELSE.
      ft_zgdtxdt0002-itamtlast  = t_vbrkf-examtlast.
      ft_zgdtxdt0002-itdisclast = t_vbrkf-itdiscexlast.
    ENDIF.
    ft_zgdtxdt0002-bilref = t_vbrkf-vbelv.
    ft_zgdtxdt0002-itcurr = ft_zgdtxdt0002-waers = t_vbrkf-waerk.
    ft_zgdtxdt0002-userid = sy-uname.

****added by Rahmadi
*---When needed to create new Faktur pajak/nota retur, selected invoice
*---consolidation option in the selection screen will be used
    ft_zgdtxdt0002-fakgr = p_flag.
****end of addition

    APPEND ft_zgdtxdt0002.
  ENDLOOP.
ENDFORM.                    "f_save_followupdocument

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prepare_data_screen.
  DATA: ld_s_table  TYPE type_data_screen OCCURS 0 WITH HEADER LINE,
        ld_s_header LIKE s_9300_header.

  DATA: ld_fax      TYPE i,
        ld_s_tables LIKE ld_s_table,
        ld_normal   LIKE vbfa-vbelv,
        ld_qty      LIKE ld_s_table-itqtylast,
        ld_qtylast  LIKE zgdtxdt0002-itqtylast,
        ld_fak      LIKE ld_s_table-fakturno,
        ld_first(1) TYPE c.


  DATA: BEGIN OF lt_02 OCCURS 0.
  DATA: vbeln      LIKE zgdtxdt0002-vbeln,
        posnr      LIKE zgdtxdt0002-posnr,
        fakturno   LIKE zgdtxdt0002-fakturno,
        itqtylast  LIKE zgdtxdt0002-itqtylast,
        itamtlast  LIKE zgdtxdt0002-itamtlast,
        itdisclast LIKE zgdtxdt0002-itdisclast,
        exclude    LIKE zgdtxdt0002-exclude,
        flag(1)    TYPE c.
  DATA: END OF lt_02.

  DATA: BEGIN OF lt_02s OCCURS 0.
          INCLUDE STRUCTURE lt_02.
        DATA: END OF lt_02s.

  REFRESH: t_vbrk_scr.

***removed by Rahmadi
*-- not relevant & not generic
*  READ TABLE t_vbrk INDEX 1.
*  CASE t_vbrk-spart.
*    WHEN d_fin_unit OR d_used.
*      PERFORM f_get_vbrkscreen_unit_usedcar.
*    WHEN d_service.
*      PERFORM f_get_vbrkscreen_sparepart.
*    WHEN d_sparts.
*      PERFORM f_get_vbrkscreen_service.
*  ENDCASE.
***end of removal

  REFRESH ld_s_table.

  LOOP AT t_vbrk_scr.
    MOVE-CORRESPONDING t_vbrk_scr TO ld_s_table.
    ld_s_table-item       = t_vbrk_scr-arktx.

    WRITE t_vbrk_scr-examtlast    CURRENCY t_vbrk_scr-waerk
          TO ld_s_table-examtlast_c.
    COMPUTE t_vbrk_scr-itdiscexlast = abs( t_vbrk_scr-itdiscexlast ).
    WRITE t_vbrk_scr-itdiscexlast CURRENCY t_vbrk_scr-waerk
          TO ld_s_table-itdiscex_c.

    ld_s_table-itqtylast = t_vbrk_scr-fkimg.

    IF p_sp_qty = 'X'.
*---- Deduct From Previous Nota Return For Split By Qty
      SELECT SUM( itqtylast )
             INTO ld_qtylast
             FROM zgdtxdt0002
             WHERE fakturno = ld_s_table-fakturno
               AND bilref = ld_s_table-vbelv.

      ld_s_table-itqtylast = ld_s_table-itqtylast - ld_qtylast.
*--------------------------------------
    ENDIF.

    APPEND ld_s_table.
  ENDLOOP.

  REFRESH lt_02.
  SELECT vbeln posnr fakturno itqtylast itamtlast itdisclast
         INTO CORRESPONDING FIELDS OF TABLE lt_02
         FROM zgdtxdt0002
         FOR ALL ENTRIES IN ld_s_table
         WHERE vbeln = ld_s_table-vbelv.

  SORT lt_02 BY fakturno.

  lt_02s[] = lt_02[].
  DELETE ADJACENT DUPLICATES FROM lt_02s COMPARING fakturno.

*----Get Faktur Number From Billing Normal
  SORT lt_02s BY fakturno.
  CLEAR: d_faks1, d_faks2, d_faks3.

  READ TABLE lt_02s INDEX 1.
  d_faks1 = lt_02s-fakturno.

  READ TABLE lt_02s INDEX 2.
  d_faks2 = lt_02s-fakturno.

  READ TABLE lt_02s INDEX 3.
  d_faks3 = lt_02s-fakturno.
*-----------------------------------------

*----- For Split By Quantitiy
  IF p_sp_qty = 'X'.

    CLEAR ld_qty.
    CLEAR ld_fak.

    SORT ld_s_table BY fakturno.

    LOOP AT ld_s_table.
      CLEAR ld_fax.
      DO 3 TIMES.
        ld_fax = ld_fax + 1.
        READ TABLE lt_02 WITH KEY vbeln = ld_s_table-vbelv
                                  posnr = ld_s_table-posnv
                                  flag  = space.
        IF sy-subrc = 0.
          lt_02-flag = 'X'.
          MODIFY lt_02 INDEX sy-tabix.
          IF lt_02-fakturno = d_faks1.
            ld_s_table-fak1 = lt_02-fakturno.
            ld_s_table-qty1 = lt_02-itqtylast.
          ELSEIF lt_02-fakturno = d_faks2.
            ld_s_table-fak2 = lt_02-fakturno.
            ld_s_table-qty2 = lt_02-itqtylast.
          ELSEIF lt_02-fakturno = d_faks3.
            ld_s_table-fak3 = lt_02-fakturno.
            ld_s_table-qty3 = lt_02-itqtylast.
          ENDIF.
          MODIFY ld_s_table.
        ENDIF.
      ENDDO.
    ENDLOOP.

* Delete Quantity = 0.
    DELETE ld_s_table WHERE itqtylast = 0.

*----- For Split By Amount
  ELSEIF p_sp_amo = 'X'.

    DELETE lt_02 WHERE fakturno = 'SPLIT BY AMOUNT'.

    SORT ld_s_table BY fakturno.

    LOOP AT ld_s_table.
      CLEAR ld_fax.
      DO 3 TIMES.
        ld_fax = ld_fax + 1.
        READ TABLE lt_02 WITH KEY vbeln = ld_s_table-vbelv
                                  flag  = space.
        IF sy-subrc = 0.
          lt_02-flag = 'X'.
          MODIFY lt_02 INDEX sy-tabix.
          IF lt_02-fakturno = d_faks1.
            ld_s_table-fak1 = lt_02-fakturno.
            ld_s_table-s_9100_io_amtlast1 = lt_02-itamtlast.
            ld_s_table-s_9100_io_disc1 = lt_02-itdisclast.
          ELSEIF lt_02-fakturno = d_faks2.
            ld_s_table-fak2 = lt_02-fakturno.
            ld_s_table-s_9100_io_amtlast2 = lt_02-itamtlast.
            ld_s_table-s_9100_io_disc2 = lt_02-itdisclast.
          ELSEIF lt_02-fakturno = d_faks3.
            ld_s_table-fak3 = lt_02-fakturno.
            ld_s_table-s_9100_io_amtlast3 = lt_02-itamtlast.
            ld_s_table-s_9100_io_disc3 = lt_02-itdisclast.
          ENDIF.
          MODIFY ld_s_table.
        ENDIF.
      ENDDO.
    ENDLOOP.

*----- For Split By Item
  ELSEIF p_sp_ite = 'X'.
  ENDIF.

  CLEAR t_vbrk.
  READ TABLE t_vbrk INDEX 1.
  ld_s_header-billing  = t_vbrk-vbeln.
  ld_s_header-customer = t_vbrk-name.
  ld_s_header-npwp     = t_vbrk-stceg.
  ld_s_header-addr1    = t_vbrk-addrs1.
  IF NOT t_vbrk-addrs2 IS INITIAL.
    CONCATENATE t_vbrk-addrs2 t_vbrk-city t_vbrk-postal
                INTO ld_s_header-addr2
                SEPARATED BY space.
  ELSE.
    CONCATENATE t_vbrk-city t_vbrk-postal
                INTO ld_s_header-addr2
                SEPARATED BY space.
  ENDIF.

  IF p_sp_qty = 'X'.
    s_9000_table[] = ld_s_table[].

  ELSEIF p_sp_ite = 'X'.
    s_9200_table[] = ld_s_table[].

  ELSEIF p_sp_amo = 'X'.
    REFRESH s_9100_table.
    s_9100_table[] = ld_s_table[].
    CLEAR: d_9100_amtlasttotal,
           d_9100_totaldisc,
           d_9100_amtlast1,
           d_9100_amtlast2,
           d_9100_amtlast3,
           d_9100_disclast1,
           d_9100_disclast2,
           d_9100_disclast3.

    DATA: ld_examtlast  LIKE t_vbrk-examtlast,
          ld_discexlast LIKE t_vbrk-itdiscexlast,
          ld_amtlast1   LIKE t_vbrk-examtlast,
          ld_amtlast2   LIKE t_vbrk-examtlast,
          ld_amtlast3   LIKE t_vbrk-examtlast,
          ld_disclast1  LIKE t_vbrk-itdiscexlast,
          ld_disclast2  LIKE t_vbrk-itdiscexlast,
          ld_disclast3  LIKE t_vbrk-itdiscexlast.

    CLEAR: ld_amtlast1,
           ld_amtlast2,
           ld_amtlast3,
           ld_examtlast,
           ld_discexlast,
           ld_disclast1,
           ld_disclast2,
           ld_disclast3.

    CLEAR: s_9100_io_amtlasttotal,
           s_9100_io_amtlast1,
           s_9100_io_amtlast2,
           s_9100_io_amtlast3,
           s_9100_io_namtlasttotal,
           s_9100_io_totaldisc,
           s_9100_io_disc1,
           s_9100_io_disc2,
           s_9100_io_disc3,
           s_9100_io_ntotaldisc.

    LOOP AT s_9100_table.
      ADD s_9100_table-examtlast    TO ld_examtlast.
      ADD s_9100_table-itdiscexlast TO ld_discexlast.
      ADD s_9100_table-s_9100_io_amtlast1  TO ld_amtlast1.
      ADD s_9100_table-s_9100_io_amtlast2  TO ld_amtlast2.
      ADD s_9100_table-s_9100_io_amtlast3  TO ld_amtlast3.
      ADD s_9100_table-s_9100_io_disc1 TO ld_disclast1.
      ADD s_9100_table-s_9100_io_disc2 TO ld_disclast2.
      ADD s_9100_table-s_9100_io_disc3 TO ld_disclast3.
    ENDLOOP.

    d_9100_waerk = s_9100_table-waerk.

    PERFORM f_convert_curr_to_integer
            USING    ld_examtlast
                     d_9100_waerk
            CHANGING d_9100_amtlasttotal.
    PERFORM f_convert_curr_to_integer
            USING    ld_amtlast1
                     d_9100_waerk
            CHANGING d_9100_amtlast1.
    PERFORM f_convert_curr_to_integer
            USING    ld_amtlast2
                     d_9100_waerk
            CHANGING d_9100_amtlast2.
    PERFORM f_convert_curr_to_integer
            USING    ld_amtlast3
                     d_9100_waerk
            CHANGING d_9100_amtlast3.

    PERFORM f_convert_curr_to_integer
            USING    ld_discexlast
                     d_9100_waerk
            CHANGING d_9100_totaldisc.
    PERFORM f_convert_curr_to_integer
            USING    ld_disclast1
                     d_9100_waerk
            CHANGING d_9100_disclast1.
    PERFORM f_convert_curr_to_integer
            USING    ld_disclast2
                     d_9100_waerk
            CHANGING d_9100_disclast2.
    PERFORM f_convert_curr_to_integer
            USING    ld_disclast3
                     d_9100_waerk
            CHANGING d_9100_disclast3.

    s_9100_io_amtlasttotal =
           ld_amtlast1 + ld_amtlast2 + ld_amtlast3.
    s_9100_io_amtlast1     = d_9100_amtlast1.
    s_9100_io_amtlast2     = d_9100_amtlast2.
    s_9100_io_amtlast3     = d_9100_amtlast3.
    s_9100_io_namtlasttotal = ld_examtlast.

    s_9100_io_totaldisc = ld_disclast1 + ld_disclast2 + ld_disclast3.
    s_9100_io_disc1 = d_9100_disclast1.
    s_9100_io_disc2 = d_9100_disclast2.
    s_9100_io_disc3 = d_9100_disclast3.
    s_9100_io_ntotaldisc    = ld_discexlast.

  ENDIF.

  s_9300_header  = ld_s_header.

ENDFORM.                    " F_PREPARE_DATA_SCREEN

*---------------------------------------------------------------------*
*       FORM f_get_vbrkscreen_unit_usedcar                            *
*---------------------------------------------------------------------*
FORM f_get_vbrkscreen_unit_usedcar.
  DATA: ld_itamtlast  LIKE t_vbrk-itamtlast,
        ld_itdisclast LIKE t_vbrk-itdisclast,
        ld_dpplast    LIKE t_vbrk-dpplast,
        ld_ppnlast    LIKE t_vbrk-ppnlast,
        ld_ppnbmlast  LIKE t_vbrk-ppnbmlast,
        ld_xppnbmlast LIKE t_vbrk-xppnbmlast,
        ld_tarifxpbm  LIKE t_vbrk-tarifxpbm,
        ld_discexlast LIKE t_vbrk-itdiscexlast,
        ld_discinlast LIKE t_vbrk-itdiscinlast,
        ld_examtlast  LIKE t_vbrk-examtlast,
        ld_inamtlast  LIKE t_vbrk-inamtlast.

  IF p_vkorg = c_vkorg_mkm.
*   If mkm Finish Unit, Program only display the unit in screen,
*   we don't display accessories . So we add value from accessories into
*   unit's value, so it can equal with billing value.
    SORT t_mara BY matnr.
    LOOP AT t_vbrk.
      ADD t_vbrk-itamtlast  TO ld_itamtlast.
      ADD t_vbrk-itdisclast TO ld_itdisclast.
      ADD t_vbrk-dpplast    TO ld_dpplast.
      ADD t_vbrk-ppnlast    TO ld_ppnlast.
      ADD t_vbrk-ppnbmlast  TO ld_ppnbmlast.
      ADD t_vbrk-xppnbmlast TO ld_xppnbmlast.
      ADD t_vbrk-tarifxpbm  TO ld_tarifxpbm.
      ADD t_vbrk-itdiscexlast TO ld_discexlast.
      ADD t_vbrk-itdiscinlast TO ld_discinlast.
      ADD t_vbrk-examtlast  TO ld_examtlast.
      ADD t_vbrk-inamtlast  TO ld_inamtlast.

*      READ TABLE t_mara WITH KEY matnr = t_vbrk-matnr BINARY SEARCH.
*      IF sy-subrc = 0.
*        IF t_mara-mtart = d_zfin.
*          t_vbrk_scr = t_vbrk.
*          APPEND t_vbrk_scr.
*        ENDIF.
*      ENDIF.
      IF t_vbrk-karoseri = d_karu.
        t_vbrk_scr = t_vbrk.
        APPEND t_vbrk_scr.
      ENDIF.
    ENDLOOP.

    READ TABLE t_vbrk_scr INDEX 1.
    t_vbrk_scr-itamtlast  = ld_itamtlast.
    t_vbrk_scr-itdisclast = ld_itdisclast.
    t_vbrk_scr-dpplast    = ld_dpplast.
    t_vbrk_scr-ppnlast    = ld_ppnlast.
    t_vbrk_scr-ppnbmlast  = ld_ppnbmlast.
    t_vbrk_scr-xppnbmlast = ld_xppnbmlast.
    t_vbrk_scr-tarifxpbm  = ld_tarifxpbm.
    t_vbrk_scr-itdiscexlast = ld_discexlast.
    t_vbrk_scr-itdiscinlast = ld_discinlast.
    t_vbrk_scr-examtlast  = ld_examtlast.
    t_vbrk_scr-inamtlast  = ld_inamtlast.

    MODIFY t_vbrk_scr INDEX 1.
  ELSE.
*   If it is KTB, then display all in screen.
    t_vbrk_scr[] = t_vbrk[].
  ENDIF.
ENDFORM.                    "f_get_vbrkscreen_unit_usedcar

*---------------------------------------------------------------------*
*       FORM f_get_vbrkscreen_sparepart                               *
*---------------------------------------------------------------------*
FORM f_get_vbrkscreen_sparepart.
* Display all in screen
  t_vbrk_scr[] = t_vbrk[].
ENDFORM.                    "f_get_vbrkscreen_sparepart

*---------------------------------------------------------------------*
*       FORM f_get_vbrkscreen_service                                 *
*---------------------------------------------------------------------*
FORM f_get_vbrkscreen_service.
* Display all in screen
  t_vbrk_scr[] = t_vbrk[].
ENDFORM.                    "f_get_vbrkscreen_service

*---------------------------------------------------------------------*
*       FORM f_convert_curr_to_integer                                *
*---------------------------------------------------------------------*
FORM f_convert_curr_to_integer
     USING    fu_currnumber
              fu_currency
     CHANGING fc_integer .
  DATA ld_string(20).

  CLEAR fc_integer.

  WRITE fu_currnumber CURRENCY fu_currency TO ld_string.
  DO.
    REPLACE '.' WITH '' INTO ld_string.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
  ENDDO.
  CONDENSE ld_string NO-GAPS.
  fc_integer = ld_string.

ENDFORM.                    "f_convert_curr_to_integer

*---------------------------------------------------------------------*
*       FORM f_get_other_data                                         *
*---------------------------------------------------------------------*
FORM f_get_other_data.
* 1. Get Customer
  READ TABLE t_vbrk INDEX 1.
  IF sy-subrc = 0.
    SELECT SINGLE kunnr name1 ort01 pstlz stras stceg
           FROM   kna1
           INTO   d_kna1
           WHERE  kunnr = t_vbrk-kunrg.
  ENDIF.

* 2. Check if this billing is cancel billing or fully return
  d_flag_canc_fullyreturn = 'X'.
  LOOP AT t_vbrk.
    IF NOT t_vbrk-ppnlast IS INITIAL.
      CLEAR d_flag_canc_fullyreturn.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_GET_OTHER_DATA


*---------------------------------------------------------------------*
*       FORM f_selected_datas                                         *
*---------------------------------------------------------------------*
FORM f_selected_datas CHANGING fc_subrc.
  READ TABLE t_vbrkscr WITH KEY sel = 'X'.
  fc_subrc = sy-subrc.
  REFRESH t_vbrkscr1.
  IF fc_subrc = 0.
    t_vbrkscr1[] = t_vbrkscr[].
    DELETE t_vbrkscr1 WHERE sel NE 'X'.
  ELSE.
    MESSAGE s000(zz) WITH 'Please select record(s)'.
  ENDIF.
ENDFORM.                    " F_SELECTED_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_BY_ITEM
*&---------------------------------------------------------------------*
FORM f_split_by_item.

  PERFORM f_get_data_02_03.

  PERFORM f_save_to_table.

  PERFORM f_popup_list
          USING 'F_WRITE_NOTARETUR_LIST'
                  'List of Created Nota Retur'
                  60
                  5
                  20
                  15
                  'X'.

ENDFORM.                    " F_SPLIT_BY_ITEM

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_SCREEN
*&---------------------------------------------------------------------*
FORM f_update_screen.

  IF tabstrip-activetab = 'GABUNGAN'.

    DATA: ld_fakturno LIKE zgdtxdt0002-fakturno.

    CLEAR ld_fakturno.
    REFRESH t_vbelns.

    LOOP AT t_vbrkscr WHERE sel = 'X'.

      SELECT SINGLE fakturno
             INTO ld_fakturno
             FROM zgdtxdt0002
             WHERE vbeln = t_vbrkscr-vbelv.
      IF sy-subrc = 0.
        SELECT vbeln
        APPENDING CORRESPONDING FIELDS OF TABLE t_vbelns
               FROM zgdtxdt0002
               WHERE fakturno = ld_fakturno
        ORDER BY vbeln.     "SOH: Shell SCI Adjustment 20240222 KRS
      ENDIF.

    ENDLOOP.

    DELETE ADJACENT DUPLICATES FROM t_vbelns COMPARING ALL FIELDS.

    LOOP AT t_vbrkscr.
      READ TABLE t_vbelns WITH KEY vbeln = t_vbrkscr-vbelv.
      IF sy-subrc = 0.
        t_vbrkscr-sel = 'X'.
        MODIFY t_vbrkscr TRANSPORTING sel.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " F_UPDATE_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_LOCKED_NORM_BILLINGS
*&---------------------------------------------------------------------*
FORM f_process_locked_norm_billings USING fu_vbrk LIKE t_vbrk
                                          fu_user
                                          fu_subrc.

  IF fu_subrc = 1.
    t_error-vbeln = fu_vbrk-vbelv.
    CONCATENATE 'Billing is locked by' fu_user INTO t_error-msg
                                       SEPARATED BY space.
    APPEND t_error.
  ELSEIF fu_subrc = 2 OR
         fu_subrc = 3.
    t_error-vbeln = fu_vbrk-vbelv.
    t_error-msg = 'Error when processing the billing'.
    APPEND t_error.
  ENDIF.

ENDFORM.                    " F_PROCESS_LOCKED_NORM_BILLINGS

*---------------------------------------------------------------------*
*       FORM f_exclude_ppn_value                                      *
*---------------------------------------------------------------------*
FORM f_exclude_ppn_value
     USING    VALUE(fu_include_ppn)
              VALUE(fu_tax_procent)
     CHANGING VALUE(fc_exclude_ppn).
  fc_exclude_ppn =  fu_include_ppn / ( 1 + fu_tax_procent ).
ENDFORM.                    "f_exclude_ppn_value

*---------------------------------------------------------------------*
*       FORM f_include_ppn_value                                      *
*---------------------------------------------------------------------*
FORM f_include_ppn_value
     USING    VALUE(fu_exclude_ppn)
              VALUE(fu_tax_procent)
     CHANGING VALUE(fc_include_ppn).
  fc_include_ppn = fu_exclude_ppn +
                   ( fu_exclude_ppn * fu_tax_procent ).
ENDFORM.                    "f_include_ppn_value

*&---------------------------------------------------------------------*
*&      Form  F_CRTFAKTURPAJAK_AMOUNT
*&---------------------------------------------------------------------*
FORM f_crtfakturpajak_lastamount
     USING    fu_vbeln
              fu_posnr
              fu_itamt
              fu_examt
              fu_inamt
              fu_itdisc
              fu_itdiscex
              fu_itdiscin
              fu_ppn
              fu_itqty
              fu_exclude
     CHANGING fc_itamtlast
              fc_examtlast
              fc_inamtlast
              fc_itdisclast
              fc_itdiscexlast
              fc_itdiscinlast
              fc_dpplast
              fc_ppnlast
              fc_itqtylast.
  CLEAR:
    fc_itamtlast,
    fc_examtlast,
    fc_inamtlast,
    fc_itdisclast,
    fc_itdiscexlast,
    fc_itdiscinlast,
    fc_dpplast,
    fc_ppnlast,
    fc_itqtylast.

  DATA:
    ld_mode_include_exclude.

  LOOP AT t_priceall
       WHERE   vbeln = fu_vbeln AND
               posnr = fu_posnr.
    CASE t_priceall-ptype.
*     Get New Amount
      WHEN d_ptype_npex OR d_ptype_nz.
        ld_mode_include_exclude = 'E'.
        ADD t_priceall-kwert TO fc_examtlast.
      WHEN d_ptype_npin.
        ld_mode_include_exclude = 'I'.
        ADD t_priceall-kwert TO fc_inamtlast.
*     Get New Discount
      WHEN d_ptype_ndex.
        ld_mode_include_exclude = 'E'.
        ADD t_priceall-kwert TO fc_itdiscexlast.
      WHEN d_ptype_ndin.
        ld_mode_include_exclude = 'I'.
        ADD t_priceall-kwert TO fc_itdiscinlast.
    ENDCASE.
  ENDLOOP.

* GET Vat %
  DATA: ld_tax_procent LIKE t_priceall-kbetr,
        ld_vatout      LIKE t_priceall-kwert.
  PERFORM f_get_vat_out
          USING    fu_vbeln
                   fu_posnr
          CHANGING ld_tax_procent
                   ld_vatout.

  IF fu_exclude = 'X'.
    IF ld_mode_include_exclude = 'E'.
*     Get Last Amount from New Amount - Old Amount
      fc_examtlast = fc_examtlast - fu_examt.
      fc_itamtlast = fc_examtlast.

*     Get Last Discount from New Discount - Old Discount
      fc_itdiscexlast = fc_itdiscexlast - fu_itdiscex.
      fc_itdisclast   = fc_itdiscexlast.

    ELSEIF ld_mode_include_exclude = 'I'.
      fc_inamtlast = fc_inamtlast - fu_inamt.
*     Get Last amount-exclude ppn from this value!
      PERFORM f_exclude_ppn_value
              USING    fc_inamtlast
                       ld_tax_procent
              CHANGING fc_itamtlast.

      fc_itdiscinlast = fc_itdiscinlast - fu_itdiscin.
*     Get Last Discount - exclude ppn from this value!
      PERFORM f_exclude_ppn_value
              USING    fc_itdiscinlast
                       ld_tax_procent
              CHANGING fc_itdisclast.

    ENDIF.
  ELSE.
    IF ld_mode_include_exclude = 'E'.
*     Get Last Amount - exclude ppn - from New Amount - Old Amount
      fc_examtlast = fc_examtlast - fu_examt.
      PERFORM f_include_ppn_value
              USING    fc_examtlast
                       ld_tax_procent
              CHANGING fc_itamtlast.

*     Get Last Discount - exclude ppn from this value!
      fc_itdiscexlast = fc_itdiscexlast - fu_itdiscex.
      PERFORM f_include_ppn_value
              USING    fc_itdiscexlast
                       ld_tax_procent
              CHANGING fc_itdisclast.

    ELSEIF ld_mode_include_exclude = 'I'.
*     Get Last Amount from New Amount - Old Amount
      fc_inamtlast = fc_inamtlast - fu_inamt.
      fc_itamtlast = fc_inamtlast.

*     Get Last Discount from New Discount - Old Discount
      fc_itdiscinlast = fc_itdiscinlast - fu_itdiscin.
      fc_itdisclast = fc_itdiscinlast.
    ENDIF.
  ENDIF.

* Get Last DPP
  PERFORM f_determine_dpp
          USING    fc_examtlast
                   fc_itdiscexlast
          CHANGING fc_dpplast.

* Get Last ppn
  fc_ppnlast = abs( fu_ppn ).

* Get Last qty
  fc_itqtylast = fu_itqty.
ENDFORM.                    " F_CRTFAKTURPAJAK_AMOUNT

*&---------------------------------------------------------------------*
*&      Form  f_screen_preview
*&---------------------------------------------------------------------*
FORM f_screen_preview.
  SET PF-STATUS 'STAT_PREV'.
  d_dynnr = '5000'.
  CALL SCREEN 5000.

ENDFORM.                    " f_screen_preview

*&---------------------------------------------------------------------*
*&      Form  f_check_noret
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_noret.

  DATA ld_noret LIKE zgdtxdt0002-noretur.

  SELECT SINGLE * FROM vbrk
                  WHERE vbeln = s_vbeln-low.
  IF sy-subrc = 0.
    SELECT SINGLE noretur
                  INTO ld_noret
                  FROM zgdtxdt0002
                  WHERE kunnr = vbrk-kunrg AND
                        noretur = p_noret.
    IF sy-subrc = 0.
      SELECT SINGLE *
        FROM zgdtx_0014
        WHERE bukrs   = p_brnch
          AND noretur = p_noret
          AND datab <= sy-datum
          AND datbi >= sy-datum.
      IF sy-subrc <> 0.
        MESSAGE e000(zab) WITH 'Nota retur'
                               p_noret
                              'has been used by the same customer before'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_check_noret
