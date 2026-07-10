*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNE0012F01                                           *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_closing.

  DATA ld_lock_subrc LIKE sy-subrc.

  CHECK p_masa NE space.
  CHECK ( sy-tcode EQ c_tcode_c OR sy-tcode EQ c_tcode_p
  OR sy-tcode EQ c_tcode_n ).

*  PERFORM f_lock_object USING 'TAX' space space 'ZGDTXdt0012'.

****Added by Rahmadi
*-- removed temporarily
**-Lock Tax period
*  CLEAR ld_lock_subrc.
*  PERFORM f_lock_tax_period CHANGING ld_lock_subrc.
*  CHECK ld_lock_subrc = 0.
*--end of temporary removal

*-Get Billing Document type
  DATA ld_fkart LIKE zgdtxdt0009-fkart.
  DATA ld_ptype LIKE zgdtxdt0009-ptype.
  CLEAR zgdtxdt0009.
  r_fkart-sign = 'I'.
  r_fkart-option = 'EQ'.
  SELECT fkart ptype
         FROM zgdtxdt0009 INTO (ld_fkart, ld_ptype)
         WHERE ptype IN (c_type_n,c_type_r,c_type_p).
    IF sy-subrc = 0.
      r_fkart-low = ld_fkart.
      APPEND r_fkart.
      t_fkart09-fkart = ld_fkart.
      t_fkart09-ptype = ld_ptype.
      APPEND t_fkart09.
    ENDIF.
  ENDSELECT.

**-Add NON TRADE DOCUMENT TYPE
*  r_fkart-low = 'ARNT'.
*  APPEND r_fkart.
*  r_fkart-low = 'ARNR'.
*  APPEND r_fkart.
*
*  t_fkart09-fkart = 'ARNT'.
*  t_fkart09-ptype = c_type_n.
*  APPEND t_fkart09.
*  t_fkart09-fkart = 'ARNR'.
*  t_fkart09-ptype = c_type_r.
*  APPEND t_fkart09.

  SORT t_fkart09 BY fkart.
****End of addition

  CASE sy-tcode.
*---when closing pajak cabang
    WHEN c_tcode_c.
***added by Rahmadi
*      PERFORM f_lock_branch.
      PERFORM f_get_org.
***end of addition
      PERFORM f_closing_cabang.

*---when closing pajak pusat
    WHEN c_tcode_p.
***added by Rahmadi
*      PERFORM f_lock_company.
      PERFORM f_get_org.
***end of addition
      PERFORM f_closing_pusat.

*---when closing pajak nasional
    WHEN c_tcode_n.        "APPLICABLE FOR TEMPO
***added by Rahmadi
*-----Get Holding company branch
      CLEAR d_hold_brnch.
      d_hold_brnch = d_hold.
*      PERFORM f_lock_nasional.
      PERFORM f_closing_nasional.
***end of addition

  ENDCASE.

***need to Reactivate??? --- Rahmadi
*  PERFORM f_unlock_object USING 'TAX' space space 'ZGDTXdt0012'.

ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_7011_UPDATE_TX04
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cab_7011_update_tx04.
  DATA lt_tx04 LIKE t_tx04 OCCURS 0 WITH HEADER LINE.
  DATA ld_msg(100).
  DATA ld_masatx LIKE t_tx04-masatx.

  CLEAR ld_msg.

*-Check whether pusat-business area tax period already been created
  SELECT *
  FROM zgdtxdt0004
  INTO TABLE lt_tx04
  WHERE
****Changed by Rahmadi
*        vkorg     EQ   p_vkorg AND
*        gsber     LIKE c_gsber_pusat AND
        bukrs     EQ   p_bukrs AND
        brnch     EQ   d_ho_brnch AND
****End of changes
        masatx    EQ   p_masa.
  IF sy-subrc NE 0.
*---pusat tax period hasnt been created-->cannot create
*   new business area tax period
    CONCATENATE text-i07 text-i08
    INTO ld_msg SEPARATED BY space.
    MESSAGE i000(zab) WITH ld_msg.
  ELSE.
    READ TABLE lt_tx04 INDEX 1.
    IF NOT lt_tx04-closedat  IS INITIAL.
*-----current pusat tax period already been closed
*     cannot created new current business area tax period
      MESSAGE i000 WITH text-i06.
    ELSE.
      IF okcode EQ 'CRET'.
        CLEAR zgdtxdt0004-closedat.
        SELECT SINGLE masatx
        INTO ld_masatx
        FROM zgdtxdt0004
        WHERE
******Modified by Rahmadi
*              vkorg     EQ   p_vkorg and
*              gsber     EQ   p_gsber and
              bukrs     EQ   p_bukrs AND
              brnch     EQ   p_brnch AND
******End of modification
              masatx    EQ   p_masan AND
              closedat  EQ   zgdtxdt0004-closedat.
        IF sy-subrc EQ 0.
          CLEAR ld_msg.

          CONCATENATE 'Tax period' p_masan 'has been opened'
          INTO ld_msg SEPARATED BY space.
          MESSAGE i000 WITH text-e66 text-e67 ld_msg.
        ELSE.
          PERFORM f_cab_createtp_gsber.
        ENDIF.
      ELSE.
*-----current pusat tax period already created
*     n not yet closed, so can create new bus. area tax period
        PERFORM f_cab_createtp_gsber.
      ENDIF.
    ENDIF.

  ENDIF.

  CLEAR : lt_tx04,lt_tx04[],
          ld_msg,
          ld_masatx.

ENDFORM.                    " F_7011_UPDATE_TX04

*&---------------------------------------------------------------------*
*&      Form  F_7012_UPDATE_TX04
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cab_7012_update_tx04.
  DATA lt_tx04 LIKE t_tx04 OCCURS 0 WITH HEADER LINE.
  DATA ld_msg(100).
  DATA lt_masatx_smallest LIKE zgdtxdt0004-masatx.
  DATA ld_gsber LIKE t_tx04-gsber.
  CLEAR ld_msg.

*-the next tax period hasnt been filled by user
  IF tn_tx04-masatx IS INITIAL.
    MESSAGE i000 WITH text-e01.
    EXIT.
  ENDIF.

  CLEAR zgdtxdt0004-closedat.
  SELECT SINGLE MIN( masatx )
  FROM zgdtxdt0004
  INTO lt_masatx_smallest
  WHERE
***Modified by Rahmadi
*        vkorg     EQ p_vkorg and
*        gsber     EQ p_gsber and
        bukrs     EQ p_bukrs AND
        brnch     EQ p_brnch AND
***End of modification
        closedat  EQ zgdtxdt0004-closedat.
  IF sy-subrc EQ 0.
    IF lt_masatx_smallest NE p_masa.
      CLEAR ld_msg.
      CONCATENATE text-i14 p_gsber text-i15
      INTO ld_msg SEPARATED BY space.
      MESSAGE i000(zab) WITH ld_msg text-i19.
      EXIT.
    ENDIF.
  ENDIF.

  SELECT *
  FROM zgdtxdt0004
  INTO TABLE lt_tx04
  WHERE
***Modified by Rahmadi
*        vkorg     EQ p_vkorg and
*    AND gsber     LIKE c_gsber_pusat
*    AND gsber     LIKE c_pusat_xxx
        bukrs     EQ p_bukrs AND
        brnch     EQ d_ho_brnch AND
***End of modification
        masatx    EQ   p_masa.
  IF sy-subrc NE 0.
*---pusat tax period hasnt been created
***Modified by Rahmadi
*    ld_gsber = p_gsber.
**    ld_gsber+1(3) = c_gsber_pusat+1(3).
*    ld_gsber+1(3) = c_pusat_xxx+1(3).
*    CONCATENATE text-i07 ld_gsber
*    INTO ld_msg SEPARATED BY space.
    CONCATENATE text-i07 d_ho_brnch
    INTO ld_msg SEPARATED BY space.
***End of modification
    MESSAGE i000 WITH ld_msg text-i18 p_masa.
  ELSE.
*---current pusat tax period has been created
    READ TABLE lt_tx04 INDEX 1.
    IF NOT lt_tx04-closedat  IS INITIAL.
*-----current pusat tax period has been closed
      MESSAGE i000 WITH text-i26.
    ELSE.
*-----current pusat tax period hasnt been closed yet
      PERFORM f_cab_7012_closetp_gsber.
    ENDIF.
  ENDIF.

  CLEAR : lt_tx04,lt_tx04[],
  ld_msg,
  ld_gsber.

ENDFORM.                    " F_7012_UPDATE_TX04

*&---------------------------------------------------------------------*
*&      Form  F_GD_TX04_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_gdcb_tx04_init.

***commented out by Rahmadi
*  ts_tx04-vkorg  = p_vkorg.
*  ts_tx04-gsber  = p_gsber.
***end of comment

  ts_tx04-masatx = p_masa.
  ts_tx04-bukrs  = p_bukrs.
  ts_tx04-brnch  = p_brnch.

***commented out by Rahmadi
*  PERFORM f_gd_vkorgt USING    p_vkorg
*                      CHANGING ts_tx04-vkorgt.
*
*  PERFORM f_gd_gsbert USING    p_gsber
*                      CHANGING ts_tx04-gsbert.
***end of comment

*---Added by Rahmadi
**Get Company code text
  ts_tx04-butxt = d_butxt.

**Get Branch text
  ts_tx04-bdesc = d_bdesc.
*---End of addition

ENDFORM.                    " F_GD_TX04_INIT

*&---------------------------------------------------------------------*
*&      Form  F_GD_VKORGT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_VKORG  text
*      <--P_TS_TX04_VKORGT  text
*----------------------------------------------------------------------*
FORM f_gd_vkorgt USING    fu_vkorg
                 CHANGING fc_vkorgt.

  SELECT SINGLE vtext
  FROM tvkot INTO fc_vkorgt
  WHERE vkorg EQ fu_vkorg
    AND spras EQ sy-langu.

ENDFORM.                    " F_GD_VKORGT

*&---------------------------------------------------------------------*
*&      Form  F_GD_GSBERT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_GSBER  text
*      <--P_TS_TX04_GSBERT  text
*----------------------------------------------------------------------*
FORM f_gd_gsbert USING    fu_gsber
                 CHANGING fc_gsbert.

  SELECT SINGLE gtext
  FROM tgsbt INTO fc_gsbert
  WHERE gsber EQ fu_gsber
    AND spras EQ sy-langu.

ENDFORM.                    " F_GD_GSBERT

*&---------------------------------------------------------------------*
*&      Form  F_GD_TX04_UPD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_gdcb_tx04_upd.
  CLEAR : t_tx04_upd,t_tx04_upd[].

  t_tx04_upd[] = t_tx04[].

  PERFORM f_clear04 TABLES t_tx04_upd.

  READ TABLE t_tx04_upd INDEX 1.
  ts_tx04 = t_tx04_upd.

***commented out by Rahmadi
*  PERFORM f_gd_vkorgt USING    p_vkorg
*                      CHANGING ts_tx04-vkorgt.
*
*  PERFORM f_gd_gsbert USING    p_gsber
*                      CHANGING ts_tx04-gsbert.
***end of comment

*---Added by Rahmadi
**Get Company code text
  ts_tx04-bukrs = d_butxt.

**Get Branch text
  ts_tx04-bdesc = d_bdesc.
*---End of addition

ENDFORM.                    " F_GD_TX04_UPD

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_CABANG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_closing_cabang.
  DATA lt_tx04 LIKE zgdtxdt0004.
  DATA ld_vkorg LIKE vbrk-vkorg.
  DATA ld_msg(100).
  DATA ld_msg_closed(60).
  DATA ld_masa LIKE vbak-erdat.

  CLEAR : ld_msg_closed,ld_masa.

  SELECT *
  FROM zgdtxdt0004
  INTO TABLE t_tx04
  WHERE
***commented by Rahmadi
*    vkorg    EQ p_vkorg and
*    gsber    EQ p_gsber and
***end of comment
    bukrs    EQ p_bukrs AND
    brnch    EQ p_brnch AND
    masatx   EQ p_masa.

  PERFORM f_clear04 TABLES t_tx04.

  IF sy-subrc NE 0.
    CLEAR: zgdtxdt0004-closedat.
    SELECT SINGLE *
    FROM zgdtxdt0004
    INTO lt_tx04
    WHERE
****Modified by Rahmadi
*          vkorg    EQ p_vkorg and
*          gsber    EQ p_gsber and
          bukrs    EQ p_bukrs AND
          brnch    EQ p_brnch AND
****End of modification
          closedat EQ zgdtxdt0004-closedat.
    IF sy-subrc EQ 0.
      CLEAR ld_msg.
****Modified by Rahmadi
*      CONCATENATE text-i12 p_gsber
*      text-i13 INTO ld_msg SEPARATED BY space.
      CONCATENATE 'Tax period for branch' p_brnch
                  'already open'
                  INTO ld_msg SEPARATED BY space.
****End of modification
      MESSAGE i000 WITH ld_msg.
    ELSE.
*-----no selected gsber exist-->option to create the new one
      PERFORM f_gdcb_tx04_init.
      CLEAR : lt_tx04,ld_vkorg,ld_msg,ld_msg_closed,ld_masa.
      CALL SCREEN 7011.
    ENDIF.
  ELSE.
    READ TABLE t_tx04 INDEX 1.
    IF t_tx04-closedat IS INITIAL.

*-----selected gsber exist and not yet closed
      CLEAR ld_vkorg.
      SELECT SINGLE vkorg   "WHY VKORG???
      INTO ld_vkorg
      FROM zgdtxdt0004
      WHERE
****Modified by Rahmadi
*          vkorg    EQ p_vkorg and
*          gsber    EQ c_gsber_pusat and
          bukrs    EQ p_bukrs AND
          brnch    EQ d_ho_brnch AND
****End of modification
          masatx EQ p_masa.
      IF sy-subrc EQ 0.
*-------current pusat tax period exist
        PERFORM f_gdcb_tx04_upd.
        CLEAR : lt_tx04,ld_vkorg,ld_msg,ld_msg_closed,ld_masa.
        CALL SCREEN 7012.
      ELSE.
*-------check current pusat tax period doesnt exist
        CLEAR ld_msg.

        CONCATENATE text-i14
****Modified by Rahmadi
*                    p_gsber
                    p_brnch
****End of modification
                    text-i15
        INTO ld_msg SEPARATED BY space.
        MESSAGE i000(zab) WITH ld_msg.

        CLEAR ld_msg.
        CONCATENATE text-i16 p_masa text-i17
        INTO ld_msg SEPARATED BY space.
        MESSAGE i000(zab) WITH ld_msg.
      ENDIF.
    ELSE.
*-----selected gsber exist and already been closed
      WRITE p_masa TO ld_masa USING EDIT MASK '____.__'.
      CONCATENATE 'Tax period' ld_masa 'for'
****Modified by Rahmadi
*      t_tx04-gsber
      t_tx04-brnch
****End of modification
      ' has been closed'
      INTO ld_msg_closed
      SEPARATED BY space.
      MESSAGE i000(zab) WITH ld_msg_closed.
    ENDIF.
  ENDIF.

  CLEAR : lt_tx04,ld_vkorg,ld_msg,ld_msg_closed,ld_masa.

ENDFORM.                    " F_GET_DATA_CABANG

*&---------------------------------------------------------------------*
*&      Form  F_7012_UPDATE_TX04_DATA1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cab7012_tx04_amountdata.

*-closing amount data
  PERFORM f_cab_7012_tx04_data.

  PERFORM f_cab_7012_tx05.

  PERFORM f_cab_7012_collect_tx04_upd.

  READ TABLE t_tx04_upd WITH KEY dki = ' '.
  CHECK sy-subrc EQ 0.

****Modified by Rahmadi
*  CHECK t_tx04_upd-gsber+1(3) NE c_gsber_pusat+1(3).
  CHECK t_tx04_upd-brnch NE d_ho_brnch.
****End of modification

  PERFORM f_cab_7012_non_dki.

ENDFORM.                    " F_7012_UPDATE_TX04_DATA1

*&---------------------------------------------------------------------*
*&      Form  F_7012_TX04_DATA1_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cab_7012_tx04_data.
*--PPN-IN (PPN masukan)
  SELECT
            bukrs
            gsber
            brnch  "added by Rahmadi
            spart
            busln  "added by Rahmadi
            belnr
            budat
            buzei
            gjahr
            fakturno
            fakdat
            masatx
            credit
*            itamt     "changed by Rahmadi 05/03/2004
            fakppn     "changed by Rahmadi 05/03/2004
            waers  "added by Rahmadi
  FROM zgdtxdt0012
  INTO CORRESPONDING FIELDS OF TABLE t_tx12
  WHERE
***Modified by Rahmadi
*        bukrs  EQ p_vkorg AND
*        gsber  EQ p_gsber AND
        bukrs  EQ p_bukrs AND
        brnch  EQ p_brnch AND
***End of modification
*    spart  NE space and
*    gjahr  NE space and
        fakturno NE space AND
        masatx EQ p_masa AND
        credit IN (c_credit_c,c_credit_i,c_credit_r).

*--PPN-OTSTD (PPN keluaran standard)
*--PPN-WAPU  (PPN keluaran standard WAPU)
  SELECT
              vkorg
              bukrs       "added by Rahmadi
              gsber
              brnch       "added by Rahmadi
              spart
              busln       "added by Rahmadi
              fakturno
              masatx
              batal
              returcount
              fakppn
              fakppnbm
              wapu
              form
              flaga2
              waerk
    FROM zgdtxdt0003
    INTO CORRESPONDING FIELDS OF TABLE t_tx03
    WHERE
***Modified by Rahmadi
*        bukrs  EQ p_vkorg AND
*        gsber  EQ p_gsber AND
          bukrs  EQ p_bukrs AND
          brnch  EQ p_brnch AND
***End of modification
*      spart  NE space and
          fakturno NE space AND
          masatx EQ p_masa AND
          batal  NE c_batal_x AND
          returcount LT 1.

*--PPN-OTSTD (PPN keluaran standard)
*--PPN-OTSDA (PPN keluaran sederhan)

*****Modified by Rahmadi
*  SELECT
*              x~vkorg
*              x~gsber
*              x~spart
*              x~vbeln
*              x~posnr
*              x~gjahr
*              x~fakturno
*              x~fkart
*              x~masatx
*              x~ppnlast
*              x~ppnbmlast
*              x~pstyv
*              x~wapu
*              y~ptype
*    FROM zGDTXdt0002 AS x INNER JOIN zGDTXdt0009 AS y
*                       ON x~fkart = y~fkart
*    INTO TABLE t_tx02
*    WHERE x~vkorg    EQ p_vkorg
*      AND x~gsber    EQ p_gsber
*      AND x~masatx   EQ p_masa
*      AND y~ptype    IN (c_type_n,c_type_r,c_type_p).

  DATA lt_tx04 LIKE t_tx04 OCCURS 0 WITH HEADER LINE.
  PERFORM f_t_tx02 TABLES t_tx02
                          lt_tx04
                   USING  ''.
****End of modification

ENDFORM.                    " F_7012_TX04_DATA1_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_PUSAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_closing_pusat.
  DATA ld_msg_gsber LIKE zgdtxdt0004-gsber.
  DATA ld_msg_brnch LIKE zgdtxdt0004-brnch.
  DATA lt_tx04 LIKE t_tx04 OCCURS 0 WITH HEADER LINE.
  DATA ld_msg(100).

*-Check whether current national tax period already been created
  SELECT SINGLE *
  FROM zgdtxdt0004
  INTO lt_tx04
  WHERE
****Modified by Rahmadi
*        vkorg  = c_vkorg_nasio (maybe need to define National CC?)
*    AND gsber  = c_gsber_nasio
        bukrs  = p_bukrs
    AND brnch  = d_hold
****End of modification
    AND masatx = p_masa.

  IF sy-subrc NE 0.
*---current national tax period hasnt been created
    CLEAR ld_msg.
    CONCATENATE text-i09 text-i08
    INTO ld_msg SEPARATED BY space.
    MESSAGE i000 WITH ld_msg.
    EXIT.
  ENDIF.

  break ibm_rahmadi.

*-t_tx04s[]: All BRNCH belong to HEAD OFFICE CCODE(including HO itself)
  SELECT *
  FROM zgdtxdt0004
  INTO TABLE t_tx04s
  WHERE
****Modified by Rahmadi
*        vkorg    EQ p_vkorg
        bukrs    EQ p_bukrs
****End of modification
    AND masatx   EQ p_masa.

*-Header level data at screen
****Added by Rahmadi
  ts_tx04-bukrs = p_bukrs.
  ts_tx04-butxt = d_butxt.
****End of addition
  ts_tx04-masatx = p_masa.

***commented out by rahmadi
*  ts_tx04-vkorg  = p_vkorg.
*
*  PERFORM f_gd_vkorgt USING    p_vkorg
*                      CHANGING ts_tx04-vkorgt.
***end of comment

*-VKORG-GSBER master data
  break bcrmd.

*** Modified by Rahmadi
*  SELECT DISTINCT bukrs gsber
*  FROM zpygfdt_tgsber
*  INTO TABLE t_gsber
*  WHERE bukrs     EQ p_vkorg
*    AND live_date NE c_live_date99.
  SELECT DISTINCT brnch bukrs bdesc
  FROM zgdtxdt0101
  INTO CORRESPONDING FIELDS OF TABLE t_gsber
  WHERE bukrs     EQ p_bukrs.

  t_ho[] = t_gsber[].
  t_branch[] = t_gsber[].
  DELETE t_ho WHERE ho_ind IS initial.
  DELETE t_branch WHERE NOT ho_ind IS initial.
*** End of modification

  t_tx04[] = t_tx04s[].

*-t_tx04s[] : All BRNCH belongs to CCODE PUSAT(excluding pusat)
*  DELETE t_tx04s WHERE gsber+1(3) EQ c_gsber_pusat+1(3).
***Modified by Rahmadi
**  DELETE t_tx04s WHERE gsber+1(3) EQ c_pusat_xxx+1(3).
*  DELETE t_tx04s WHERE brnch EQ d_ho_brnch.

  PERFORM f_pusat_tx04_text.
***End of modification
  IF t_tx04[] IS INITIAL.
*---gsber pusat (VKORG:P_VKORG/GSBER:N000) not yet exist
    CLEAR: ld_msg_gsber, lt_tx04, lt_tx04[], ld_msg, ld_msg_brnch.
    CALL SCREEN 7021.
  ELSE.
    READ TABLE t_tx04 WITH KEY
**** modified by Rahmadi
*                               vkorg = p_vkorg
                               bukrs = p_bukrs
*                               gsber+1(3) = c_gsber_pusat+1(3).
*                               gsber+1(3) = c_pusat_xxx+1(3).
                               brnch = d_ho_brnch.
**** End of modification
    IF sy-subrc EQ 0.
      IF t_tx04-closedat IS INITIAL.
        ts_tx04_masat = c_status_open.
      ELSE.
        ts_tx04_masat = c_status_close.
      ENDIF.

**** Modified by Rahmadi
*      SORT t_tx04s BY vkorg gsber masatx.
*      SORT t_tx04b BY vkorg gsber masatx.
      SORT t_tx04s BY bukrs brnch masatx.
      SORT t_tx04b BY bukrs brnch masatx.
**** End of modification
      break ibm_rahmadi.
      IF okcode EQ 'EXEC'.
        CLEAR : ld_msg_gsber, ld_msg_brnch, lt_tx04,lt_tx04[],ld_msg.
        LEAVE SCREEN.
        SET SCREEN 7022.
      ELSE.
        CLEAR : ld_msg_gsber, ld_msg_brnch, lt_tx04,lt_tx04[],ld_msg.
        CALL SCREEN 7022.
      ENDIF.
    ELSE.
      READ TABLE t_tx04 INDEX 1.
      CLEAR : ld_msg,ld_msg_gsber, ld_msg_brnch.
*      CONCATENATE t_tx04-gsber(1) '000' INTO ld_msg_gsber.
***modified by Rahmadi
*      CONCATENATE t_tx04-gsber(1) 'XXX' INTO ld_msg_gsber.
      ld_msg_brnch = d_ho_brnch.
***end of modification
      CONCATENATE
*      text-i07
***modified by Rahmadi
*      ld_msg_gsber
      ld_msg_brnch
***end of modification
      text-i08
      INTO ld_msg SEPARATED BY space.
      MESSAGE i000(zab) WITH ld_msg.
    ENDIF.
  ENDIF.

  CLEAR : ld_msg_gsber, ld_msg_brnch, lt_tx04,lt_tx04[],ld_msg.

ENDFORM.                    " F_GET_DATA_PUSAT

*&---------------------------------------------------------------------*
*&      Form  F_GDPS_TX04_UPD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pusat_tx04_text.
  DATA ld_index LIKE sy-tabix.

  CHECK NOT t_tx04s[] IS INITIAL.

***commented out by Rahmadi
*-Company codes & business areas text
*  SELECT *
*  FROM tvkot INTO TABLE t_vkorgt
*  FOR ALL ENTRIES IN t_tx04s
*  WHERE vkorg EQ t_tx04s-vkorg
*    AND spras EQ sy-langu.
*
*  SELECT *
*  FROM tgsbt INTO TABLE t_gsbert
*  FOR ALL ENTRIES IN t_tx04s
*  WHERE gsber EQ t_tx04s-gsber
*    AND spras EQ sy-langu.
*  SORT t_vkorgt BY vkorg.
*  SORT t_gsbert BY gsber.
***end of comment

*-VKORG & GSBER text
  LOOP AT t_tx04s.
    ld_index = sy-tabix.
    CLEAR : t_vkorgt,t_gsbert.

****Modified by Rahmadi
*    READ TABLE t_vkorgt WITH KEY vkorg = t_tx04s-vkorg BINARY SEARCH.
*    READ TABLE t_gsbert WITH KEY gsber = t_tx04s-gsber BINARY SEARCH.
*
*    t_tx04s-gsbert = t_gsbert-gtext.
*    t_tx04s-vkorgt = t_vkorgt-vtext.
    READ TABLE t_gsber WITH KEY brnch = t_tx04s-brnch.

    t_tx04s-butxt = d_butxt.
    t_tx04s-bdesc = t_gsber-bdesc.

*    MODIFY t_tx04s INDEX ld_index TRANSPORTING vkorgt gsbert.
    MODIFY t_tx04s INDEX ld_index TRANSPORTING butxt bdesc.
****end of modification

  ENDLOOP.

*-(S)udah & (B)elum Closed
  t_tx04b[] = t_tx04s[].

  DELETE t_tx04s WHERE closedat IS initial.
  DELETE t_tx04b WHERE NOT closedat IS initial.

  CLEAR ld_index.

ENDFORM.                    " F_GDPS_TX04_UPD

*&---------------------------------------------------------------------*
*&      Form  F_7021_UPDATE_TX04
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pusat_7021_update_tx04.

  IF NOT t_tx04b[] IS INITIAL.
*---There's any unclosed gsber under Pusat
    MESSAGE i000(zab) WITH text-i04.
  ELSE.
*---create new tax period for all GSBER belongs to VKORG
    CLEAR : t_tx04_upd,t_tx04_upd[].

    t_tx04_upd-masatx = ts_tx04-masatx.

    LOOP AT t_gsber.
***modified by Rahmadi
*      t_tx04_upd-vkorg  = t_gsber-bukrs.
*      t_tx04_upd-gsber  = t_gsber-gsber.
      t_tx04_upd-bukrs  = t_gsber-bukrs.
      t_tx04_upd-brnch  = t_gsber-brnch.
***end of modification
      t_tx04_upd-userid = sy-uname.
      APPEND t_tx04_upd.
    ENDLOOP.

    break ibm_rahmadi.

***added by Rahmadi
    DATA ld_lock_subrc LIKE sy-subrc.
    CLEAR ld_lock_subrc.
    PERFORM f_release_tax_period CHANGING ld_lock_subrc.
    CHECK ld_lock_subrc = 0.
***end of addition

    MODIFY zgdtxdt0004  FROM TABLE t_tx04_upd.
    CHECK ( sy-subrc EQ 0 AND sy-dbcnt NE 0 ).
    MESSAGE s000(zab) WITH text-s02.

  ENDIF.
ENDFORM.                    " F_7021_UPDATE_TX04

*&---------------------------------------------------------------------*
*&      Form  F_7022_UPDATE_TX04
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pusat_7022_update_tx04.
  IF tn_tx04-masatx IS INITIAL.
    MESSAGE i000 WITH text-e01.
    EXIT.
  ENDIF.

  IF NOT t_tx04b[] IS INITIAL.

    CALL SCREEN 7024 STARTING AT 15 5
                     ENDING AT 80 15.
  ELSE. "all business area under pusat has already been closed
    PERFORM f_pusat_7022_main_close.
  ENDIF.
ENDFORM.                    " F_7022_UPDATE_TX04

*&---------------------------------------------------------------------*
*&      Form  F_7024DISP_UNCLOSED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_7024disp_unclosed.
  PERFORM f_header_pop7024.
  LOOP AT t_tx04b.
    WRITE : / sy-vline,
***modified by Rahmadi
*            (12) t_tx04b-vkorg,sy-vline,
*            (6)  t_tx04b-gsber,sy-vline,
*            (30) t_tx04b-gsbert,sy-vline.
            (12) t_tx04b-bukrs,sy-vline,
            (6)  t_tx04b-brnch,sy-vline,
            (30) t_tx04b-bdesc,sy-vline.
***End of modification
  ENDLOOP.
  WRITE : /(58) sy-uline.
ENDFORM.                    " F_7024DISP_UNCLOSED

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_user_command.
  CASE sy-pfkey.
*---pop up display unclosed tax period
    WHEN 'ST7024'.
      CASE sy-ucomm.
        WHEN 'CONT'.
          PERFORM f_7024_pop_continue.
        WHEN 'CANC'.
          LEAVE SCREEN.
      ENDCASE.
    WHEN OTHERS.
  ENDCASE.
  CLEAR: okcode.
ENDFORM.                    " F_CHECK_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_POP7024
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_header_pop7024.
  SKIP.

  WRITE : / 'Following branches have not been closed'.
  WRITE : /(58) sy-uline .
  WRITE : / sy-vline,
            (12) 'Head Office', sy-vline,
            (6)  'Branch'      , sy-vline,
            (30) 'Branch desc' , sy-vline.
  WRITE : /(58) sy-uline.
ENDFORM.                    " F_HEADER_POP7024

*&---------------------------------------------------------------------*
*&      Form  F_7024_POP_CONTINUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_7024_pop_continue.
*-close all unclosed gsber & update tax amounts
  PERFORM f_pusat_7024_popc_update_data.

*-refresh screen with the updated data
  PERFORM f_closing_pusat.
ENDFORM.                    " F_7024_POP_CONTINUE

*&---------------------------------------------------------------------*
*&      Form  F_7024_POPC_UPDATE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pusat_7024_popc_update_data.
  CLEAR : t_tx04_upd,t_tx04_upd[].

  t_tx04_upd[] = t_tx04b[].

  PERFORM f_clear04 TABLES t_tx04_upd.

*-closing date
  READ TABLE t_tx04_upd INDEX 1.
  t_tx04_upd-closedat = sy-datum.
  MODIFY t_tx04_upd TRANSPORTING closedat WHERE closedat IS initial.

*-closing tax amount data
  PERFORM f_pusat_7024_tx04_data.

  PERFORM f_pusat_7024_tx04_data_nondki.

*-create new TP for unclosed gsber
  LOOP AT t_tx04b.
    CLEAR t_tx04_upd.
    t_tx04_upd-vkorg  = t_tx04b-vkorg.
    t_tx04_upd-gsber  = t_tx04b-gsber.
****added by Rahmadi
    t_tx04_upd-bukrs  = t_tx04b-bukrs.
    t_tx04_upd-brnch  = t_tx04b-brnch.
****end of addition
    t_tx04_upd-masatx = tn_tx04-masatx.
    t_tx04_upd-dki    = t_tx04b-dki.
    APPEND t_tx04_upd.
  ENDLOOP.

*-userid
  t_tx04_upd-userid = sy-uname.
  MODIFY t_tx04_upd TRANSPORTING userid
  WHERE userid NE sy-uname.

  break ibm_rahmadi.

***added by Rahmadi
  DATA ld_lock_subrc LIKE sy-subrc.
  CLEAR ld_lock_subrc.
  PERFORM f_release_tax_period CHANGING ld_lock_subrc.
  CHECK ld_lock_subrc = 0.
***end of addition

*-close current period for unclosed gsber and create the new ones
  MODIFY zgdtxdt0004  FROM TABLE t_tx04_upd.
  CHECK ( sy-subrc EQ 0 AND sy-dbcnt NE 0 ).
  MESSAGE s000(zab) WITH text-s01.

ENDFORM.                    " F_7024_POPC_UPDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_7022_CONFIRM2CONTINUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_confirm2continue USING fu_text01
                              fu_text02
                              fu_text03
                     CHANGING fc_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
            titlebar      = fu_text01
            text_question = fu_text02
            text_button_1 = fu_text03
       IMPORTING
            answer        = fc_answer.
*"       EXCEPTIONS
*"              TEXT_NOT_FOUND


ENDFORM.                    " F_7022_CONFIRM2CONTINUE

*&---------------------------------------------------------------------*
*&      Form  F_7022_CLOSE_PUSAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_7022_close_pusat.
  CLEAR : t_tx04_p,t_tx04_p[],
          t_tx04_pst,t_tx04_pst[],
          t_tx04_upd,t_tx04_upd[].

  SELECT * FROM zgdtxdt0004
  INTO TABLE t_tx04_p
  WHERE
***modified by Rahmadi
*        vkorg  EQ   p_vkorg
*    AND gsber  LIKE c_gsber_pusat
        bukrs  EQ   p_bukrs
    AND brnch  EQ   d_ho_brnch
    AND masatx EQ   p_masa.
***end of modification

  CHECK NOT t_tx04_p[] IS INITIAL.

  SELECT * FROM zgdtxdt0004
  INTO TABLE t_tx04_pst
  WHERE
***modified by Rahmadi
*        vkorg  EQ   p_vkorg
*    AND gsber  NE space
        bukrs  EQ p_bukrs
    AND brnch  NE space
***end of modification
    AND masatx EQ p_masa.

  CHECK NOT t_tx04_pst[] IS INITIAL.

*-Pusat tax amount
  break ibm_rahmadi.
  PERFORM f_pusat_7022_tx04_value.
  PERFORM f_pusat_7022_tx05.
  PERFORM f_pusat_7022_tx04_coll_value.

*-New Pusat tax period
  PERFORM f_pusat_7022_tx04_newpusat.

  break ibm_rahmadi.
*-Closing process
***modified by Rahmadi
  DATA ld_lock_subrc LIKE sy-subrc.
  CLEAR ld_lock_subrc.
  PERFORM f_release_tax_period CHANGING ld_lock_subrc.
  CHECK ld_lock_subrc = 0.

*  MODIFY zGDTXdt0004  FROM TABLE t_tx04_upd.
*  CHECK ( sy-subrc EQ 0 AND sy-dbcnt NE 0 ).
*  MESSAGE s000(zab) WITH text-s01.
  PERFORM f_update_table ON COMMIT.
  COMMIT WORK AND WAIT.
****end of modification

ENDFORM.                    " F_7022_CLOSE_PUSAT

*&---------------------------------------------------------------------*
*&      Form  F_7022_CREATE_PUSAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pusat_7022_create_pusat.
  DATA lt_tx04_upd LIKE t_tx04_upd.

*-create new TP for gsber pusat
  READ TABLE t_tx04_upd INDEX 1.
  CHECK sy-subrc EQ 0.
  lt_tx04_upd = t_tx04_upd.

  CLEAR : t_tx04_upd,t_tx04_upd[].


  t_tx04_upd-vkorg  = lt_tx04_upd-vkorg.
  t_tx04_upd-gsber  = lt_tx04_upd-gsber.
  t_tx04_upd-masatx = tn_tx04-masatx.
  t_tx04_upd-userid = sy-uname.
  APPEND t_tx04_upd.

  break ibm_rahmadi.

***added by Rahmadi
  DATA ld_lock_subrc LIKE sy-subrc.
  CLEAR ld_lock_subrc.
  PERFORM f_release_tax_period CHANGING ld_lock_subrc.
  CHECK ld_lock_subrc = 0.
***end of addition

*-create new gsber pusat tax period
  MODIFY zgdtxdt0004  FROM TABLE t_tx04_upd.

ENDFORM.                    " F_7022_CREATE_PUSAT


*&---------------------------------------------------------------------*
*&      Form  F_7022_MAIN_CLOSE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pusat_7022_main_close.
  DATA ld_7022_answer LIKE d_7022_answer.

  PERFORM f_confirm2continue USING text-ph1 text-p01 text-pb1
                                  CHANGING ld_7022_answer.

  IF ld_7022_answer EQ '1'.
*---close tax period & collect taxs amount for business area pusat only
*---create new tax period for business are pusat
    PERFORM f_7022_close_pusat.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " F_7022_MAIN_CLOSE

*&---------------------------------------------------------------------*
*&      Form  F_7024_TX04_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pusat_7024_tx04_data.
  PERFORM f_nas_ccpng_taxamount_gsbers.

ENDFORM.                    " F_7024_TX04_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_NASIONAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*TP : Tax Period
*----------------------------------------------------------------------*
FORM f_closing_nasional.
  DATA ld_answer LIKE d_7022_answer.

  CLEAR : d_subrc,
      t_tx04,t_tx04[],
      t_tx04s,t_tx04s[],
      t_tx04_p,t_tx04_p[],
      t_tx04b,t_tx04b[],
      ts_tx04.

  break ibm_rahmadi.
*-Check current Tax Period Nasional exist
***added by Rahmadi
  IF NOT t_tx04_upd[] IS INITIAL AND
     d_simu IS INITIAL.
    t_tx04[] = t_tx04_upd[].
    DELETE t_tx04 WHERE brnch <> d_hold OR
                        masatx <> p_masa.
  ELSE.
***end of addition
    SELECT *
    FROM zgdtxdt0004
    INTO TABLE t_tx04
    WHERE
***modified by Rahmadi
*        vkorg    EQ c_vkorg_nasio
**    AND gsber    EQ c_gsber_nasio
*    AND gsber    EQ c_nasio_xxx
          brnch    EQ d_hold
***end of modification
      AND masatx   EQ p_masa.
  ENDIF.

  IF sy-subrc EQ 0.
*---CTP nas exist
    READ TABLE t_tx04 INDEX 1.
    IF NOT t_tx04-closedat IS INITIAL.
*-----CTP nas closed
      ts_tx04_masat = c_status_close.
      IF sy-ucomm NE 'EXEC'.
        MESSAGE i000 WITH text-i10.
        EXIT.
      ELSE.
        PERFORM f_disp_befor_close_nas.
      ENDIF.
    ELSE.
*-----CTP nas open
      ts_tx04_masat  = c_status_open.
      PERFORM f_disp_befor_close_nas.
    ENDIF.
  ELSE.
*---not exist
    CLEAR : zgdtxdt0004-closedat.
    SELECT *
    FROM zgdtxdt0004
    INTO TABLE t_tx04
    WHERE
***modified by Rahmadi
*          vkorg    EQ c_vkorg_nasio
*      AND gsber    EQ c_gsber_nasio
          brnch    EQ d_hold
***end of modification
      AND closedat EQ zgdtxdt0004-closedat.
    IF sy-subrc EQ 0.
      MESSAGE i000 WITH text-i11.
    ELSE.
      PERFORM f_confirm2continue USING text-ph1 text-p02 text-pb3
                              CHANGING ld_answer.
      IF ld_answer EQ '1'.
        PERFORM f_create_nasional.
      ENDIF.

    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DATA_NASIONAL

*&---------------------------------------------------------------------*
*&      Form  F_SEL_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_sel_screen.
  DATA ld_msg(100).
  DATA ld_lena TYPE i.
  DATA ld_lenn TYPE i.
  DATA ld_seli TYPE i.
  DATA ld_bukrs LIKE t001-bukrs.
  DATA ld_gsber LIKE vbrp-gsber.
  DATA ld_masa LIKE sy-datum.
  DATA ld_masn LIKE sy-datum.

  CLEAR : ld_msg,ld_lena,ld_lenn,ld_seli,ld_gsber,ld_masa,ld_masn,
          d_branch_num, d_hold.

**{temporary disabled for testing
*  IF sy-tcode EQ c_tcode_c.
*    PERFORM f_check_run.
*  ENDIF.
**}

  ld_masa = p_masa.
  ld_masn = p_masan.
  SHIFT : ld_masa LEFT DELETING LEADING '0',
          ld_masn LEFT DELETING LEADING '0'.

  ld_lena = strlen( ld_masa ).
  ld_lenn = strlen( ld_masn ).
  ld_seli = p_masan - p_masa.

  IF ld_lena LT 6.
    MESSAGE e000(zab) WITH text-m01.
  ENDIF.

  IF ( p_masa+4(2) GT 12 OR p_masa+4(2) LT 1 ).
    MESSAGE e000(zab) WITH text-m01.
  ENDIF.

  IF sy-tcode = c_tcode_n.  "nasional
****added by Rahmadi
    IF p_hold IS INITIAL.
      MESSAGE e000(zab) WITH 'Please enter Holding company branch'.
    ELSE.
      SELECT brnch bukrs hcompany ho_ind
             INTO CORRESPONDING FIELDS OF TABLE t_national
             FROM zgdtxdt0101
             WHERE hcompany = p_hold.
      IF sy-subrc <> 0.
        MESSAGE e000(zab) WITH 'The branch is not holding company'.
      ELSE.
*---------Determine whether National branch is the ONLY branch
*---------------------------------------------------------------------*
* If the holding company is the ONLY branch within the org structure, *
* performing national tax period closing means performing closing to  *
* the whole org structure                                             *
*---------------------------------------------------------------------*
        DESCRIBE TABLE t_national LINES d_branch_num.

        READ TABLE t_national WITH KEY brnch = p_hold.
        d_hold = t_national-hcompany.
        p_bukrs = t_national-bukrs.

        IF d_branch_num = 1.
          p_brnch = t_national-brnch.
        ENDIF.

*-------get head offices
        t_ho[] = t_national[].
        t_branch[] = t_national[].
        DELETE t_ho WHERE ho_ind IS initial.
        DELETE t_branch WHERE NOT ho_ind IS initial.
      ENDIF.
    ENDIF.
*      IF p_brnch <> d_hold.
*        MESSAGE e000(zab)
*                WITH 'The Branch is not Holding company'.
*      ENDIF.
****end of addition

    IF ld_lenn LT 6.
      MESSAGE e000(zab) WITH text-m02.
    ENDIF.
    IF ( p_masan+4(2) GT 12 OR p_masan+4(2) LT 1 ).
      MESSAGE e000(zab) WITH text-m01.
    ENDIF.
    IF p_masa GE p_masan.
      MESSAGE e000(zab) WITH text-e05.
    ENDIF.
****changed for MKM 09/02/2004
*    IF NOT ( ld_seli EQ 1 OR ld_seli EQ 89 ).
****changed for Tempo --- enable for 3 months
*    IF NOT ( ld_seli EQ 2 OR ld_seli EQ 90 ).
    IF NOT ( ld_seli EQ 3 OR ld_seli EQ 91 ).
****end of changes
      MESSAGE e000(zab) WITH text-m02.
    ENDIF.

  ENDIF.

****added by Rahmadi
*--Calling Tax System Organization Structure
  CALL FUNCTION 'Z_GDTXFC_TAX_CFG_ORG_DETMN'
       EXPORTING
            fi_brnch                      = p_brnch
*            fi_busln                      =
            fi_bukrs                      = p_bukrs
       IMPORTING
            fe_bukrs                      = ld_bukrs
            fe_busds                      = d_busds
            fe_bdesc                      = d_bdesc
            fe_ho_ind                     = d_ho
            fe_hold                       = d_hold
       TABLES
            ft_tx00101                    = t_txdt00101
            ft_tx00102                    = t_txdt00102
            ft_tx00103                    = t_txdt00103
       EXCEPTIONS
            company_code_not_assigned     = 1
            business_line_not_maintained  = 2
            branch_config_not_maintained  = 3
            busline_config_not_maintained = 4
            taxconsol_config_not_maintain = 5
            OTHERS                        = 6.
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
        MESSAGE e000(zab) WITH 'No company code assigned to branch'.
      WHEN 2 OR 4.
        MESSAGE e000(zab) WITH 'No business line maintained'.
      WHEN 3.
        MESSAGE e000(zab) WITH 'No branch maintained'.
      WHEN 5.
        MESSAGE e000(zab) WITH 'Tax Consolidation config table'
                               'is not maintained'.
      WHEN OTHERS.
        MESSAGE e000(zab) WITH 'Error!'.
    ENDCASE.
  ENDIF.

*-Get Company code text
  SELECT SINGLE butxt INTO d_butxt FROM t001
                      WHERE bukrs = p_bukrs.
****end of addition


  CASE sy-tcode.
    WHEN c_tcode_c. "Cabang
*      IF p_gsber+1(3) EQ c_gsber_pusat+1(3).

***modified by Rahmadi
*      IF p_gsber+1(3) EQ c_pusat_xxx+1(3).
      IF NOT p_brnch IS INITIAL AND
         NOT d_ho IS INITIAL.
***end of modification
        CONCATENATE 'Branch' p_brnch text-m03 INTO
        ld_msg SEPARATED BY space.
        MESSAGE e000(zab) WITH ld_msg.
      ENDIF.
*      IF p_gsber EQ c_gsber_nasio.

***Modified by Rahmadi
*      IF p_gsber EQ c_nasio_xxx.
*        MESSAGE e000(zab) WITH text-e09.
*      ENDIF.
*
      IF d_hold = p_brnch.
        MESSAGE e000(zab)
                WITH 'Branch'
                     p_brnch
                     'is holding company. Please use National Closing'.
      ENDIF.
***End of modification

***deleted by Rahmadi -- already catered in Function module
*      IF ( p_vkorg IS INITIAL OR
*           p_gsber IS INITIAL ).
*        MESSAGE e000(zab) WITH text-e03.
*      ELSE.
*        SELECT SINGLE gsber
*        FROM zpygfdt_tgsber
*        INTO ld_gsber
*        WHERE bukrs EQ p_vkorg
*          AND gsber EQ p_gsber.
*        IF sy-subrc EQ 0.
*        ELSE.
*          MESSAGE e000(zab) WITH text-e07.
*        ENDIF.
*      ENDIF.
***end of deletion

    WHEN c_tcode_p.   "Pusat
***modified by Rahmadi
*      IF p_vkorg IS INITIAL.
      IF p_bukrs IS INITIAL.
***end of modification
        MESSAGE e000(zab) WITH text-e04.
      ENDIF.

***Added by Rahmadi
      IF NOT p_brnch IS INITIAL.
        IF d_ho IS INITIAL.
          MESSAGE e000(ztx) WITH 'The branch is not Head office'.
        ENDIF.
      ENDIF.
***End of addition


***Nasional - Modified by Rahmadi
*      IF p_vkorg EQ c_vkorg_nasio.
*        MESSAGE e000(zab) WITH text-e08.
*      ENDIF.

*      IF NOT d_hold IS INITIAL.
*        MESSAGE e000(zab) WITH text-e08.
*      ENDIF.
      IF d_hold = p_brnch.
        MESSAGE e000(zab)
                WITH 'Branch'
                     p_brnch
                     'is holding company. Please use National Closing'.
      ENDIF.
***End of modification

***deleted by Rahmadi -- already catered in Function module
*      SELECT SINGLE bukrs
*      FROM zpygldt_plantref
*      INTO ld_bukrs
*      WHERE bukrs EQ p_vkorg.
*      IF sy-subrc NE 0.
*        MESSAGE e000(zab) WITH text-e11.
*      ENDIF.
***end of deletion
  ENDCASE.

  CLEAR : ld_msg,
  ld_lena,
  ld_lenn,
  ld_seli,
  ld_bukrs,
  ld_gsber,
  ld_masa,
  ld_masn.

ENDFORM.                    " F_SEL_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_SEL_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_sel_screen_output.

  LOOP AT SCREEN.
    IF screen-group1 = 'DSP'.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

**Check National Closing?
  CLEAR zgdtxdt0004-closedat.
  SELECT SINGLE masatx
  INTO p_masa
  FROM zgdtxdt0004
  WHERE
***modified by Rahmadi
*    vkorg    EQ c_vkorg_nasio AND
**    AND gsber    EQ c_gsber_nasio
*    gsber    EQ c_nasio_xxx AND
    brnch    EQ d_hold AND
***end of modification
    closedat EQ zgdtxdt0004-closedat.
  IF sy-subrc EQ 0.
***changed for Tempo --- Tax open period for 3 mths
*    p_masan = p_masa + 2.
    p_masan = p_masa + 3.
***end of Tempo changes
    IF p_masa+4(2) = '12'.          "MKM
***changed for Tempo --- Tax open period for 3 mths
*      p_masan+4(2) = '02'.          "MKM
      p_masan+4(2) = '03'.
***end of Tempo changes
      p_masan(4) = p_masan(4) + 1.
    ELSEIF p_masa+4(2) = '11'.      "MKM
***changed for Tempo --- Tax open period for 3 mths
*      p_masan+4(2) = '01'.          "MKM
      p_masan+4(2) = '02'.
***end of Tempo changes
      p_masan(4) = p_masan(4) + 1.  "MKM
***added for Tempo --- tax open for 3 mths
    ELSEIF p_masa+4(2) = '10'.
      p_masan+4(2) = '01'.
      p_masan(4) = p_masan(4) + 1.
***end of Tempo addition
    ENDIF.
  ENDIF.
**end of comment

  CASE sy-tcode.

    WHEN c_tcode_c.
      LOOP AT SCREEN.
        IF screen-group1 = 'CPN'.
          screen-input = '0'.
          screen-invisible = '1'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

      CLEAR zgdtxdt0004-closedat.
      SELECT SINGLE masatx
      INTO p_masa
      FROM zgdtxdt0004
      WHERE
**** modified by Rahmadi
*        vkorg    EQ p_vkorg and
*        gsber    EQ p_gsber and
        bukrs    EQ p_bukrs AND
        brnch    EQ p_brnch AND
**** end of modification
        closedat EQ zgdtxdt0004-closedat.
      IF sy-subrc EQ 0.
***changed for Tempo --- Tax open period for 3 mths
*    p_masan = p_masa + 2.
        p_masan = p_masa + 3.
***end of Tempo changes
        IF p_masa+4(2) = '12'.          "MKM
***changed for Tempo --- Tax open period for 3 mths
*      p_masan+4(2) = '02'.          "MKM
          p_masan+4(2) = '03'.
***end of Tempo changes
          p_masan(4) = p_masan(4) + 1.
        ELSEIF p_masa+4(2) = '11'.      "MKM
***changed for Tempo --- Tax open period for 3 mths
*      p_masan+4(2) = '01'.          "MKM
          p_masan+4(2) = '02'.
***end of Tempo changes
          p_masan(4) = p_masan(4) + 1.  "MKM
***added for Tempo --- tax open for 3 mths
        ELSEIF p_masa+4(2) = '10'.
          p_masan+4(2) = '01'.
          p_masan(4) = p_masan(4) + 1.
***end of Tempo addition
        ENDIF.
      ENDIF.

    WHEN c_tcode_p.
      LOOP AT SCREEN.
        IF screen-group1 = 'CPN'
        OR screen-name   = 'P_GSBER'
        OR screen-name   = '%_P_GSBER_%_APP_%-TEXT'.
          screen-input = '0'.
          screen-invisible = '1'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

      CLEAR zgdtxdt0004-closedat.
      SELECT SINGLE masatx
      INTO p_masa
      FROM zgdtxdt0004
      WHERE
**** modified by Rahmadi
*        vkorg    EQ p_vkorg AND
**        gsber    LIKE c_gsber_pusat and
*        gsber    EQ c_pusat_xxx and
****end of modification
        bukrs    EQ p_bukrs AND
        brnch    EQ p_brnch AND
        closedat EQ zgdtxdt0004-closedat.
      IF sy-subrc EQ 0.
***changed for Tempo --- Tax open period for 3 mths
*    p_masan = p_masa + 2.
        p_masan = p_masa + 3.
***end of Tempo changes
        IF p_masa+4(2) = '12'.          "MKM
***changed for Tempo --- Tax open period for 3 mths
*      p_masan+4(2) = '02'.          "MKM
          p_masan+4(2) = '03'.
***end of Tempo changes
          p_masan(4) = p_masan(4) + 1.
        ELSEIF p_masa+4(2) = '11'.      "MKM
***changed for Tempo --- Tax open period for 3 mths
*      p_masan+4(2) = '01'.          "MKM
          p_masan+4(2) = '02'.
***end of Tempo changes
          p_masan(4) = p_masan(4) + 1.  "MKM
***added for Tempo --- tax open for 3 mths
        ELSEIF p_masa+4(2) = '10'.
          p_masan+4(2) = '01'.
          p_masan(4) = p_masan(4) + 1.
***end of Tempo addition
        ENDIF.
      ENDIF.

***** APPLICABLE FOR MKM
    WHEN c_tcode_n.
      LOOP AT SCREEN.
        IF screen-group1 = 'CPC'.
          screen-input = '0'.
          screen-invisible = '1'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

      CLEAR zgdtxdt0004-closedat.
      SELECT SINGLE masatx
      INTO p_masa
      FROM zgdtxdt0004
      WHERE
*      vkorg    EQ c_vkorg_nasio and
**            AND gsber    EQ c_gsber_nasio
*      gsber    EQ c_nasio_xxx and
        brnch    EQ p_hold AND
        closedat EQ zgdtxdt0004-closedat.
      IF sy-subrc EQ 0.
***changed for Tempo --- Tax open period for 3 mths
*    p_masan = p_masa + 2.
        p_masan = p_masa + 3.
***end of Tempo changes
        IF p_masa+4(2) = '12'.          "MKM
***changed for Tempo --- Tax open period for 3 mths
*      p_masan+4(2) = '02'.          "MKM
          p_masan+4(2) = '03'.
***end of Tempo changes
          p_masan(4) = p_masan(4) + 1.
        ELSEIF p_masa+4(2) = '11'.      "MKM
***changed for Tempo --- Tax open period for 3 mths
*      p_masan+4(2) = '01'.          "MKM
          p_masan+4(2) = '02'.
***end of Tempo changes
          p_masan(4) = p_masan(4) + 1.  "MKM
***added for Tempo --- tax open for 3 mths
        ELSEIF p_masa+4(2) = '10'.
          p_masan+4(2) = '01'.
          p_masan(4) = p_masan(4) + 1.
***end of Tempo addition
        ENDIF.
      ENDIF.
****** End of comment - Rahmadi

  ENDCASE.

ENDFORM.                    " F_SEL_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_CN_CLOSECREATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_nas_closecreate_nasional.
  DATA lt_tx04 LIKE t_tx04.

  CLEAR : t_tx04_upd.
***removed by Rahmadi
*          t_tx04_upd[].
***end of removal

*-closing tax amount data
  break ibm_rahmadi.

***removed by Rahmadi
*  PERFORM f_cncc_taxamount_new.
*  PERFORM f_cncc_taxamount_add.
***end of removal

  IF d_simu <> 'X'.
*---closing date
***modified by Rahmadi
*    READ TABLE t_tx04_upd INDEX 1.
    READ TABLE t_tx04_upd WITH KEY brnch = p_hold.
***end of modification
    t_tx04_upd-closedat = sy-datum.
    MODIFY t_tx04_upd TRANSPORTING closedat WHERE closedat IS initial.

*---new tax period Nasional
***added by Rahmadi
    lt_tx04-bukrs  = t_tx04_upd-bukrs.
    lt_tx04-brnch  = t_tx04_upd-brnch.
    lt_tx04-hcompany = t_tx04_upd-hcompany.
***end of addition
    lt_tx04-vkorg  = t_tx04_upd-vkorg.
    lt_tx04-gsber  = t_tx04_upd-gsber.
    CLEAR : t_tx04_upd.
***added by Rahmadi
    t_tx04_upd-bukrs   = lt_tx04-bukrs.
    t_tx04_upd-brnch   = lt_tx04-brnch.
    t_tx04-hcompany    = lt_tx04-hcompany.
***end of addition
    t_tx04_upd-vkorg   = lt_tx04-vkorg.
    t_tx04_upd-gsber   = lt_tx04-gsber.
    t_tx04_upd-masatx  = p_masan.
    APPEND t_tx04_upd.

****Removed by Rahmadi -- USELESS??? REDUNDANT ???
*    READ TABLE t_tx04 INDEX 1.
*    CLEAR : t_tx04_upd.
****added by Rahmadi
*    t_tx04_upd-bukrs   = t_tx04-bukrs.
*    t_tx04_upd-brnch   = t_tx04-brnch.
****end of addition
*    t_tx04_upd-vkorg     = t_tx04-vkorg.
*    t_tx04_upd-gsber     = t_tx04-gsber.
*    t_tx04_upd-masatx    = p_masa.
*    t_tx04_upd-closedat  = sy-datum.
*    APPEND t_tx04_upd.
*
*    CLEAR : t_tx04_upd.
****added by Rahmadi
*    t_tx04_upd-bukrs   = t_tx04-bukrs.
*    t_tx04_upd-brnch   = t_tx04-brnch.
****end of addition
*    t_tx04_upd-vkorg     = t_tx04-vkorg.
*    t_tx04_upd-gsber     = t_tx04-gsber.
*    t_tx04_upd-masatx    = p_masan.
*    APPEND t_tx04_upd.
****end of removal

  ENDIF.

*-userid
  t_tx04_upd-userid = sy-uname.
  MODIFY t_tx04_upd TRANSPORTING userid
  WHERE userid NE sy-uname.

*  IF d_simu EQ 'X'.
*    PERFORM f_nas_simulation_only.
*  ENDIF.

****added by Rahmadi
*  PERFORM f_closing_report.
****end of addition

***removed by Rahmadi
*  PERFORM f_update_table.
***end of removal

****added by Rahmadi
  break ibm_rahmadi.
  IF d_simu IS INITIAL.
    PERFORM f_update_table ON COMMIT.
    COMMIT WORK AND WAIT.
****end of addition
  ENDIF.

ENDFORM.                    " F_CN_CLOSECREATE

*---------------------------------------------------------------------*
*       FORM f_update_table                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_update_table.

*-close current TP Pusat & create the new one
***added by Rahmadi
  IF NOT t_tx04_upd_brnch[] IS INITIAL.
    APPEND LINES OF t_tx04_upd_brnch TO t_tx04_upd.
  ENDIF.
***end of addition

  break ibm_rahmadi.

***added by Rahmadi
  DATA ld_lock_subrc LIKE sy-subrc.
  CLEAR ld_lock_subrc.
  PERFORM f_release_tax_period CHANGING ld_lock_subrc.
  CHECK ld_lock_subrc = 0.
***end of addition

  MODIFY zgdtxdt0004 FROM TABLE t_tx04_upd.
  IF sy-subrc EQ 0
     AND sy-dbcnt NE 0.
    IF d_simu EQ 'X'.
      MESSAGE s000 WITH text-i77.
    ELSE.
      MESSAGE i000 WITH text-i10.
    ENDIF.
****added by Rahmadi
  ELSE.
    MESSAGE a000(zab) WITH 'Closing Error!'.
  ENDIF.
****end of addition

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CLOSECREATE_PUSATNGSBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_nas_closecreate_pusatngsber.
  CLEAR d_clocing_succeeded.

  IF d_simu = 'X'.
*---simulation case : all closed tax period masih diikutkan di simulasi
    CLEAR : t_tx04_p,t_tx04_p[].

*{   REPLACE        P01K910446                                        1
*\    SELECT * FROM zgdtxdt0004
*\    INTO TABLE t_tx04_p
*\***added by Rahmadi
*\    FOR ALL ENTRIES IN t_ho
*\***end of addition
*\    WHERE
*\****modified by Rahmadi
*\*          vkorg  NE   space
*\*      AND gsber  LIKE c_gsber_pusat
*\*      AND gsber  NE   c_gsber_nasio
*\          bukrs NE space
*\      AND brnch = t_ho-brnch
*\*        AND brnch NE d_hold
*\****end of modification
*\      AND masatx EQ   p_masa.
    "Start SOH: Shell SCI Adjustment 20240222 KRS
    SELECT * FROM zgdtxdt0004
    INTO TABLE t_tx04_p
***added by Rahmadi
    FOR ALL ENTRIES IN t_ho
***end of addition
    WHERE
****modified by Rahmadi
*          vkorg  NE   space
*      AND gsber  LIKE c_gsber_pusat
*      AND gsber  NE   c_gsber_nasio
          bukrs NE space
      AND brnch = t_ho-brnch
*        AND brnch NE d_hold
****end of modification
      AND masatx EQ   p_masa
      ORDER BY PRIMARY KEY.
      "SOH: Shell SCI Adjustment 20240222 KRS
*}   REPLACE
  ENDIF.

***modified by Rahmadi
  break ibm_rahmadi.
  CLEAR : t_tx04_upd,t_tx04_upd[].
  IF d_branch_num > 1 AND
     NOT t_branch[] IS INITIAL.
    PERFORM f_nas_closecreate_gsbers.
  ENDIF.
***end of modification

***added by Rahmadi
  PERFORM f_pusat_7022_tx05.
***end of addition
  PERFORM f_nas_closecreate_pusats.


ENDFORM.                    " F_CLOSECREATE_PUSATNGSBER

*&---------------------------------------------------------------------*
*&      Form  F_CCPNG_TAXAMOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_nas_ccpng_taxamount_gsbers.
  CLEAR :
          t_tx12,t_tx12[],
          t_tx02,t_tx02[],
          t_tx03,t_tx03[].

  CHECK NOT t_tx04_upd[] IS INITIAL.
*-get data from table 00012,00003,00002
  PERFORM f_nas_ccpng_get_data.
*-get all gsber's NPWP
  PERFORM f_nas_ccpng_get_tx05.
*-collect PPN amount for DKI & NONDKI(temporary)
  PERFORM f_nas_ccpng_coll_data.  "CLEANUP THIS ROUTINE !!!!

ENDFORM.                    " F_CCPNG_TAXAMOUNT

*&---------------------------------------------------------------------*
*&      Form  F_INITIALIZATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_initialization.

  CASE sy-tcode.
*---when closing pajak cabang
    WHEN c_tcode_c.
      d_title = 'Branch Tax Period Closing'.
*---when closing pajak pusat
    WHEN c_tcode_p.
      d_title = 'Central Tax Period Closing'.
*---when closing pajak nasional
    WHEN c_tcode_n.
      d_title = 'Tax Period Closing'.
*---ilegal tcode
    WHEN c_tcode_se38 OR c_tcode_se80.
      LEAVE PROGRAM.
  ENDCASE.
ENDFORM.                    " F_INITIALIZATION

*&---------------------------------------------------------------------*
*&      Form  F_CLOSING_GSBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cab_createtp_gsber.
  CLEAR : t_tx04_upd,t_tx04_upd[].

*-create 1 new tax period for business area p_gsber
****Added by Rahmadi
  t_tx04_upd-bukrs  = ts_tx04-bukrs.
  t_tx04_upd-brnch  = ts_tx04-brnch.
****End of addition
  t_tx04_upd-vkorg  = ts_tx04-vkorg.
  t_tx04_upd-gsber  = ts_tx04-gsber.
  t_tx04_upd-masatx = ts_tx04-masatx.
  t_tx04_upd-userid = sy-uname.
  APPEND t_tx04_upd.

  break ibm_rahmadi.

***added by Rahmadi
  DATA ld_lock_subrc LIKE sy-subrc.
  CLEAR ld_lock_subrc.
  PERFORM f_release_tax_period CHANGING ld_lock_subrc.
  CHECK ld_lock_subrc = 0.
***end of addition

  MODIFY zgdtxdt0004  FROM TABLE t_tx04_upd.
  CHECK sy-subrc EQ 0.

  IF sy-ucomm EQ 'CRET'.
    ts_tx04-masatx = d_masatx.
*    MESSAGE i000(zab) WITH text-s03.
****modified by Rahmadi
*    MESSAGE i000(zab) WITH text-s06 ts_tx04-gsber text-s07.
    MESSAGE i000(zab) WITH text-s06 ts_tx04-brnch text-s07.
****end of modification
    LEAVE TO SCREEN 0.
  ELSE.
*    MESSAGE s000(zab) WITH text-s03.
****modified by Rahmadi
*    MESSAGE i000(zab) WITH text-s06 ts_tx04-gsber text-s07.
    MESSAGE i000(zab) WITH text-s06 ts_tx04-brnch text-s07.
****end of modification
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " F_CLOSING_GSBER

*&---------------------------------------------------------------------*
*&      Form  F_CLOSETP_GSBER
*&---------------------------------------------------------------------*
*-Close Tax Period For Business Area p_gsber
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cab_7012_closetp_gsber.
  DATA lt_tx04_upd LIKE t_tx04_upd.

*-closing date (only for record that's goin 2 be closed)
  t_tx04_upd-closedat = sy-datum.
  MODIFY t_tx04_upd INDEX 1 TRANSPORTING closedat.

*-closing amount data
  PERFORM f_cab7012_tx04_amountdata.

*-append next tax period for business area p_gsber
  READ TABLE t_tx04_upd INDEX 1.
  lt_tx04_upd = t_tx04_upd.
  CLEAR : t_tx04_upd.
  t_tx04_upd-vkorg  = lt_tx04_upd-vkorg.
  t_tx04_upd-gsber  = lt_tx04_upd-gsber.
  t_tx04_upd-masatx = tn_tx04-masatx.
  t_tx04_upd-dki    = lt_tx04_upd-dki.
***Added by Rahmadi
  t_tx04_upd-bukrs  = lt_tx04_upd-bukrs.
  t_tx04_upd-brnch  = lt_tx04_upd-brnch.
***End of addition
  APPEND t_tx04_upd.

*-userid (both records)
  t_tx04_upd-userid = sy-uname.
  MODIFY t_tx04_upd TRANSPORTING userid
  WHERE userid NE sy-uname.

  break ibm_rahmadi.
***removed by Rahmadi
**-close current period & create new period
*  MODIFY zGDTXdt0004  FROM TABLE t_tx04_upd.
*  CHECK sy-subrc EQ 0.
*  MESSAGE s000(zab) WITH text-s01.
*  LEAVE TO SCREEN 0.
***end of removal

ENDFORM.                    " F_CLOSETP_GSBER

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_NASIONAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_nasional.
*-VKORG-GSBER live master data

***modified by Rahmadi
*  SELECT DISTINCT bukrs gsber
*  FROM zpygfdt_tgsber
*  INTO TABLE t_gsber
*  WHERE live_date NE c_live_date99.

*--Select all branches within the holding company - TO BE OPENED
  SELECT DISTINCT brnch bukrs bdesc
  FROM zgdtxdt0101
  INTO CORRESPONDING FIELDS OF TABLE t_gsber
  WHERE hcompany   EQ d_hold.
***end of modification

*-create new tax period for all GSBER belongs to Nasional
  CLEAR : t_tx04_upd,t_tx04_upd[].

  t_tx04_upd-masatx = p_masan.

  LOOP AT t_gsber.
***modified by Rahmadi
    t_tx04_upd-bukrs  = t_gsber-bukrs.
    t_tx04_upd-brnch  = t_gsber-brnch.
    t_tx04_upd-hcompany = d_hold.
*    t_tx04_upd-vkorg  = t_gsber-bukrs.
*    t_tx04_upd-gsber  = t_gsber-gsber.
***end of modification
    APPEND t_tx04_upd.
  ENDLOOP.

***removed by Rahmadi - USELESS??
****modified by Rahmadi
**  t_tx04_upd-vkorg  = c_vkorg_nasio.
**  t_tx04_upd-gsber  = c_gsber_nasio.
*  t_tx04_upd-bukrs  = p_bukrs.
*  t_tx04_upd-brnch  = d_hold.
*  t_tx04_upd-hcompany = d_hold.
****end of modification
*  APPEND t_tx04_upd.
***end of removal

***Comment by Rahmadi -- USELESS???
*  LOOP AT t_tx04_upd WHERE
****modified by Rahmadi
**                           gsber+1(3) EQ c_gsber_pusat+1(3).
**    t_tx04_upd-gsber+1(3)  = c_pusat_xxx+1(3).
*                           brnch EQ d_ho_brnch.
*    t_tx04_upd-brnch  = c_pusat_xxx+1(3).
****end of modification
*    APPEND t_tx04_upd.
*  ENDLOOP.
***end of comment

*-userid
  t_tx04_upd-userid = sy-uname.
  MODIFY t_tx04_upd TRANSPORTING userid
  WHERE userid NE sy-uname.

  break ibm_rahmadi.

***added by Rahmadi
  DATA ld_lock_subrc LIKE sy-subrc.
  CLEAR ld_lock_subrc.
  PERFORM f_release_tax_period CHANGING ld_lock_subrc.
  CHECK ld_lock_subrc = 0.
***end of addition

*-Open NEW PERIOD
  MODIFY zgdtxdt0004  FROM TABLE t_tx04_upd.
  CHECK ( sy-subrc EQ 0 AND sy-dbcnt NE 0 ).
  MESSAGE s000(zab) WITH text-s02.

ENDFORM.                    " F_CREATE_NASIONAL

*&---------------------------------------------------------------------*
*&      Form  F_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM f_lock_object USING fu_key1 fu_key2 fu_key3 fu_tab.
  DATA: ld_param LIKE seqta-garg,
        ld_uname LIKE sy-uname.

  CONCATENATE fu_key1 fu_key2 fu_key3 INTO ld_param.

  CALL FUNCTION 'ZPYGLFC_GENERAL_LOCK'
       EXPORTING
            fi_objnam = 'ZGDTXdt0012'
            fi_param   = ld_param
*           FI_WAIT    = ' '
*           FI_COLLECT = ' '
*      IMPORTING
*           fe_uname    = ld_uname
      EXCEPTIONS
           object_is_locked = 1
           OTHERS           = 2.

  IF sy-subrc <> 0.
    ld_uname = sy-msgv1.
    MESSAGE e000(zab) WITH 'The record is locked by' ld_uname '!'.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  F_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_unlock_object USING fu_key1 fu_key2 fu_key3 fu_tab.

  DATA: ld_param LIKE seqta-garg,
        ld_uname LIKE sy-uname.

  CONCATENATE fu_key1 fu_key2 fu_key3 INTO ld_param.

  CALL FUNCTION 'ZPYGLFC_GENERAL_UNLOCK'
       EXPORTING
*            fi_objnam = fu_tab
            fi_objnam = 'ZGDTXdt0012'
            fi_param  = ld_param
*      IMPORTING
*           FE_SUBRC  =
            .
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_TX04_UPD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_TX04_UPD  text
*----------------------------------------------------------------------*
FORM f_clear_tx04_upd USING ft_tx04_upd STRUCTURE t_tx04_upd.

  CLEAR t_tx04_upd.
  t_tx04_upd-mandt    = ft_tx04_upd-mandt.
  t_tx04_upd-vkorg    = ft_tx04_upd-vkorg.
  t_tx04_upd-gsber    = ft_tx04_upd-gsber.
  t_tx04_upd-masatx   = ft_tx04_upd-masatx.
  t_tx04_upd-closedat = ft_tx04_upd-closedat.
  t_tx04_upd-userid   = ft_tx04_upd-userid.
  t_tx04_upd-dki      = ft_tx04_upd-dki.
***Modified by Rahmadi
  t_tx04_upd-bukrs    = ft_tx04_upd-bukrs.
  t_tx04_upd-brnch    = ft_tx04_upd-brnch.
  t_tx04_upd-hcompany = ft_tx04_upd-hcompany.
  t_tx04_upd-waers    = ft_tx04_upd-waers.  "added for MKM 05/03/2004
***End of modification

ENDFORM.                    " F_CLEAR_TX04_UPD

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_FROM12
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_from12.
*(already - )
*  IF t_tx12-credit EQ c_credit_r.
*    t_tx12-itamt = t_tx12-itamt * ( -1 ).
*  ENDIF.

***modified by Rahmadi  05/03/2004
*  t_tx04_upd-ppnin = t_tx12-itamt.
  t_tx04_upd-ppnin = t_tx12-fakppn.
***end of modification
  t_tx04_upd-waers = t_tx12-waers.  "added by Rahmadi 05/03/2004
  COLLECT t_tx04_upd.

ENDFORM.                    " F_COLLECT_FROM12

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_FROM03
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_from03.
  IF t_tx03-wapu NE space.
    IF t_tx03-wapu EQ c_wapu_w.
      t_tx04_upd-ppnwapu = t_tx03-fakppn.
      t_tx04_upd-ppnbmwapu = t_tx03-fakppnbm.
    ENDIF.
  ENDIF.

  IF ( t_tx03-form EQ c_form_a2 AND t_tx03-flaga2 EQ c_flaga2_a ).
    t_tx04_upd-ppntang   = t_tx03-fakppn.
    t_tx04_upd-ppnbmtang = t_tx03-fakppnbm.
  ENDIF.

  IF ( t_tx03-form EQ c_form_a2 AND t_tx03-flaga2 EQ c_flaga2_d ).
    t_tx04_upd-ppnbas   = t_tx03-fakppn.
    t_tx04_upd-ppnbmbas = t_tx03-fakppnbm.
  ENDIF.

  t_tx04_upd-ppnotstd = t_tx03-fakppn.
  t_tx04_upd-ppnbm    = t_tx03-fakppnbm.
  t_tx04_upd-waers   = t_tx03-waerk.  "added by Rahmadi 05/03/2004
  COLLECT t_tx04_upd.

ENDFORM.                    " F_COLLECT_FROM03

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_FROM02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_from02.

  CASE t_tx02-ptype.
    WHEN c_type_n.
*      IF ( t_tx02-fakturno EQ space AND t_tx02-wapu NE c_wapu_w ).
      IF t_tx02-fakturno EQ space.
        t_tx04_upd-ppnotsda = t_tx02-ppnlast.
        t_tx04_upd-ppnbmsda = t_tx02-ppnbmlast.
      ENDIF.
    WHEN c_type_r OR
****added for MKM by Rahmadi 08/03/2004
         c_type_p.
      IF NOT t_tx02-noretur IS INITIAL.
        t_tx04_upd-ppnretur = t_tx02-ppnlast.  "original code
      ELSE.
        CLEAR t_tx04_upd-ppnretur.
      ENDIF.
****end of addition
  ENDCASE.
  t_tx04_upd-waers   = t_tx02-waers.  "added by Rahmadi 05/03/2004
  COLLECT t_tx04_upd.

ENDFORM.                    " F_COLLECT_FROM02

*&---------------------------------------------------------------------*
*&      Form  F_7032_UPDATE_TX04
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_nas_7032_update_tx04.

***added by Rahmadi
  CLEAR: t_tx04_upd, t_tx04_upd_brnch,
         t_tx04_upd[], t_tx04_upd_brnch[].
***end of addition

  IF d_simu = 'X'.
    PERFORM f_nas_closecreate_pusatngsber.
  ELSE.
    IF NOT t_tx04_p[] IS INITIAL. "any pusat & gsber not yet closed
*---Close current TP Pusat&itsGSBER & create the new one
      PERFORM f_nas_closecreate_pusatngsber.
    ENDIF.
  ENDIF.

*-Close current TP Nas & create the new one
  break bcrmd.
  READ TABLE t_tx04 INDEX 1.
  CHECK sy-subrc EQ 0.
  IF NOT t_tx04-closedat IS INITIAL.
    MESSAGE i000 WITH text-i10.
    EXIT.
  ELSE.
    PERFORM f_nas_closecreate_nasional.
*---refresh screen
    PERFORM f_closing_nasional.
  ENDIF.

****removed by Rahmadi
*****moved by Rahmadi
*  break ibm_rahmadi.
*  IF d_simu IS INITIAL.
*    PERFORM f_update_table ON COMMIT.
*    COMMIT WORK AND WAIT.
*****end of movement
*  ENDIF.
****end of removal

ENDFORM.                    " F_7032_UPDATE_TX04

*&---------------------------------------------------------------------*
*&      Form  F_GET_GSBERT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_gsbert.
  DATA ld_index LIKE sy-index.
  CHECK NOT t_tx04s[] IS INITIAL.

***modified by Rahmadi
*  SELECT gsber gtext
*  FROM tgsbt
*  INTO TABLE t_tgsbt
*  FOR ALL ENTRIES IN t_tx04s
*  WHERE gsber EQ t_tx04s-gsber
*    AND spras EQ sy-langu.
*
*  SORT t_tgsbt BY gsber.
*
*  LOOP AT t_tx04s.
*    ld_index = sy-tabix.
*    READ TABLE t_tgsbt WITH KEY gsber = t_tx04s-gsber BINARY SEARCH.
*    IF sy-subrc EQ 0.
*      t_tx04s-gsbert = t_tgsbt-gtext.
*      MODIFY t_tx04s INDEX ld_index TRANSPORTING gsbert.
*    ENDIF.
*  ENDLOOP.

  SELECT brnch bdesc
  FROM zgdtxdt0101
  INTO TABLE t_tgsbt
  FOR ALL ENTRIES IN t_tx04s
  WHERE brnch EQ t_tx04s-brnch.

  SORT t_tgsbt BY brnch.

  LOOP AT t_tx04s.
    ld_index = sy-tabix.
    READ TABLE t_tgsbt WITH KEY brnch = t_tx04s-brnch BINARY SEARCH.
    IF sy-subrc EQ 0.
      t_tx04s-bdesc = t_tgsbt-bdesc.
      MODIFY t_tx04s INDEX ld_index TRANSPORTING bdesc.
    ENDIF.
  ENDLOOP.
***end of modification





**end of modification

ENDFORM.                    " F_GET_GSBERT

*&---------------------------------------------------------------------*
*&      Form  F_CNCC_TAXAMOUNT_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cncc_taxamount_new.
  DATA lt_tx04_upd LIKE t_tx04_upd OCCURS 0 WITH HEADER LINE.

  break ibm_rahmadi.
  SELECT * FROM zgdtxdt0004
  INTO TABLE lt_tx04_upd
***added by Rahmadi
  FOR ALL ENTRIES IN t_ho
***end of addition
  WHERE
***modified by Rahmadi
*        vkorg  NE space
*    AND gsber  LIKE c_gsber_pusat
        bukrs  NE space
    AND brnch  = t_ho-brnch
***end of modification
    AND masatx EQ p_masa.

***modified by Rahmadi
*  DELETE lt_tx04_upd WHERE gsber EQ c_gsber_nasio.
  IF d_branch_num > 1.
    LOOP AT lt_tx04_upd.
      READ TABLE t_ho WITH KEY brnch = lt_tx04_upd-brnch.
      IF sy-subrc = 0.
        DELETE lt_tx04_upd.
      ENDIF.
    ENDLOOP.
  ENDIF.
***end of modification

  READ TABLE t_tx04 INDEX 1.
  LOOP AT lt_tx04_upd.
    t_tx04_upd = lt_tx04_upd.
***added by Rahmadi
    t_tx04_upd-bukrs  = t_tx04-bukrs.
    t_tx04_upd-brnch  = t_tx04-brnch.
    t_tx04_upd-hcompany = t_tx04-hcompany.
***end of addition
    t_tx04_upd-vkorg  = t_tx04-vkorg.
    t_tx04_upd-gsber  = t_tx04-gsber.
*    t_tx04_upd-gsber  = c_gsber_nasio. "<----???? NOT SURE
    t_tx04_upd-masatx = t_tx04-masatx.

*{--20020904-temporary only : PPNOTSDACAB untuk 0001,A000
*    CLEAR : t_tx04_upd-closedat,t_tx04_upd-dki,t_tx04_upd-userid.
    CLEAR : t_tx04_upd-closedat,t_tx04_upd-dki,t_tx04_upd-userid,
            t_tx04_upd-ppnotsda_cab.
*}

    COLLECT t_tx04_upd.
  ENDLOOP.
ENDFORM.                    " F_CNCC_TAXAMOUNT_NEW

*&---------------------------------------------------------------------*
*&      Form  F_DISP_BEFOR_CLOSE_NAS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_disp_befor_close_nas.
  DATA ld_index LIKE sy-tabix.
  DATA lt_tx04s LIKE ts_tx04 OCCURS 0 WITH HEADER LINE.

  break bcrmd.

  ts_tx04-masatx = p_masa.

*---Get head offices / all branches within the same holding
***added by Rahmadi
  IF NOT t_tx04_upd[] IS INITIAL.
    t_tx04_p[] = t_tx04_upd[].
    DELETE t_tx04_p WHERE masatx <> p_masa.
***removed for Tempo
****display all closed branch on the screen
*    LOOP AT t_tx04_p.
*      READ TABLE t_ho WITH KEY brnch = t_tx04_p-brnch.
*      IF sy-subrc <> 0.
*        DELETE t_tx04_p.
*      ENDIF.
*    ENDLOOP.
****end of Tempo removal
  ELSE.
***end of addition
****Get HO branch
*{   REPLACE        P01K910446                                        1
*\    SELECT *
*\    FROM zgdtxdt0004
*\    INTO TABLE t_tx04_p
*\***added by Rahmadi
*\    FOR ALL ENTRIES IN t_ho
*\***end of addition
*\    WHERE
*\***modified by rahmadi
*\**        gsber    LIKE c_gsber_pusat
*\*        brnch    EQ d_ho_brnch
*\          brnch    EQ t_ho-brnch
*\***end of modification
*\      AND masatx   EQ p_masa.
    "Start SOH: Shell SCI Adjustment 20240222 KRS
    SELECT *
    FROM zgdtxdt0004
    INTO TABLE t_tx04_p
***added by Rahmadi
    FOR ALL ENTRIES IN t_ho
***end of addition
    WHERE
***modified by rahmadi
**        gsber    LIKE c_gsber_pusat
*        brnch    EQ d_ho_brnch
          brnch    EQ t_ho-brnch
***end of modification
      AND masatx   EQ p_masa
      ORDER BY PRIMARY KEY.
   "End SOH: Shell SCI Adjustment 20240222 KRS
*}   REPLACE

***added for Tempo
    IF sy-subrc = 0 AND
       NOT t_branch[] IS INITIAL.
****Get Branch within the same HO
*{   REPLACE        P01K910446                                        2
*\      SELECT *
*\      FROM zgdtxdt0004
*\      INTO TABLE t_tx04_br
*\      FOR ALL ENTRIES IN t_branch
*\      WHERE
*\            brnch    EQ t_branch-brnch
*\        AND masatx   EQ p_masa.
      "Start SOH: Shell SCI Adjustment 20240222 KRS
      SELECT *
      FROM zgdtxdt0004
      INTO TABLE t_tx04_br
      FOR ALL ENTRIES IN t_branch
      WHERE
            brnch    EQ t_branch-brnch
        AND masatx   EQ p_masa
        ORDER BY PRIMARY KEY.
      "End SOH: Shell SCI Adjustment 20240222 KRS
*}   REPLACE
    ENDIF.
***end of Tempo addition
  ENDIF.

***Commented by Rahmadi -- NOT SURE: USELESS??
*  SELECT *
*  FROM zGDTXdt0004
*  INTO TABLE t_tx04_px
*  WHERE
****modified by Rahmadi
*        gsber    LIKE c_pusat_xxx
*        BRNCH
****end of modification
*    AND masatx   EQ p_masa.
***end of comment

***removed by Rahmadi
*    DELETE t_tx04_p WHERE
****modified by Rahmadi
**                        vkorg EQ c_vkorg_nasio
**                    AND gsber EQ c_gsber_nasio.
*                          brnch EQ d_hold.
***end of removal

***Commented by Rahmadi --- NOT SURE:USELESS???
*  DELETE t_tx04_px WHERE vkorg EQ c_vkorg_nasio
*                     AND gsber EQ c_nasio_xxx.
***end of comment

*  t_tx04s[] = t_tx04_p[].
*  PERFORM f_get_gsbert.
*  t_tx04b[] = t_tx04s[].

  t_tx04s[] = t_tx04_p[].

***added for Tempo
****append branches within the same HO
  IF NOT t_branch[] IS INITIAL AND
     t_tx04_upd[] IS INITIAL.
    APPEND LINES OF t_tx04_br TO t_tx04s.
  ENDIF.
***end of addition

  PERFORM f_get_gsbert.

***Commented by Rahmadi --- NOT SURE:USELESS???
*  lt_tx04s[] = t_tx04_px[].
*  LOOP AT lt_tx04s.
*    ld_index = sy-tabix.
*    READ TABLE t_tx04s WITH KEY vkorg = lt_tx04s-vkorg
*                             gsber(1) = lt_tx04s-gsber(1).
*    CHECK sy-subrc EQ 0.
*    lt_tx04s-gsbert = t_tx04s-gsbert.
*    MODIFY lt_tx04s INDEX ld_index TRANSPORTING gsbert.
*  ENDLOOP.
***end of comment

***commented by Rahmadi  NOT SURE? USELESS???
*  CLEAR : t_tx04s,t_tx04s[].
*  t_tx04s[] = lt_tx04s[].
***end of comment
  t_tx04b[] = t_tx04s[].

  DELETE t_tx04s WHERE closedat IS initial.
  DELETE t_tx04b WHERE NOT closedat IS initial.

***Comment by Rahmadi:  NOT SURE: USELESS ????????
*-------
*  DELETE t_tx04_p WHERE NOT closedat IS initial.
*  LOOP AT t_tx04_px.
*    CHECK NOT t_tx04_px-closedat IS INITIAL.
*    DELETE t_tx04_p WHERE vkorg    EQ t_tx04_p-vkorg
*                      AND gsber(1) EQ t_tx04_p-gsber(1).
*
*  ENDLOOP.
***end of comment

  CLEAR :
    ld_index,
    lt_tx04s,lt_tx04s[].

  IF ( okcode EQ 'EXEC' OR okcode EQ 'SIMU' ).
    LEAVE SCREEN.
    SET SCREEN 7032.
  ELSE.
    CALL SCREEN 7032.
  ENDIF.

ENDFORM.                    " F_DISP_BEFOR_CLOSE_NAS

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_RUN
*&---------------------------------------------------------------------*
*       check whether the closing date is in the end of the month or
*       or later
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_run.
  DATA ld_datum LIKE sy-datum.
  DATA ld_eom_datum LIKE sy-datum.
  CLEAR ld_eom_datum.
  ld_datum(6) = p_masa.
  ld_datum+6(2) = '01'.

***Modified by Rahmadi
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
       EXPORTING
            day_in            = ld_datum
       IMPORTING
            last_day_of_month = ld_eom_datum
       EXCEPTIONS
            day_in_no_date    = 1
            OTHERS            = 2.

*  CALL FUNCTION 'Z_END_OF_MONTH_DETERMINE'
*       EXPORTING
*            datum   = ld_datum
*       IMPORTING
*            exdatum = ld_eom_datum.
***End of modification

  CHECK sy-datum LE ld_eom_datum.
  MESSAGE e000(zab) WITH text-m88 text-m99.

  CLEAR : ld_datum, ld_eom_datum.
ENDFORM.                    " F_CHECK_RUN

*&---------------------------------------------------------------------*
*&      Form  F_GET_CAB_TX05
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cab_7012_tx05.
*  SELECT vkorg gsber
*         MAX( masafrom ) fptwo
*  FROM zGDTXdt0005
*  INTO TABLE t_cab_tx05
*  WHERE vkorg EQ p_vkorg
*    AND gsber EQ p_gsber
*  GROUP BY vkorg gsber fptwo.

*  CLEAR t_cab_tx05.
*  READ TABLE t_cab_tx05 INDEX 1.
*  SHIFT t_cab_tx05-fptwo LEFT DELETING LEADING space.

  SELECT vkorg
         bukrs
         gsber
         brnch
         masafrom
         fptwo
  FROM zgdtxdt0005
  INTO CORRESPONDING FIELDS OF TABLE t_cab_tx05
  WHERE
***Modified by Rahmadi
*        vkorg EQ p_vkorg AND
*        gsber EQ p_gsber.
        bukrs EQ p_bukrs AND
        brnch EQ p_brnch.
***End of modification

ENDFORM.                    " F_GET_CAB_TX05

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_FROM03_CAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_from03_cab.
  DATA ld_ok(1).
  CLEAR ld_ok.

**Modified by Rahmadi
*  IF t_tx03-gsber+1(3) EQ c_gsber_pusat+1(3).
  IF t_tx03-brnch EQ d_ho_brnch.
    ld_ok = 'X'.
    READ TABLE t_cab_tx05 WITH KEY
*                                   vkorg    = t_tx03-vkorg
*                                   gsber    = t_tx03-gsber
                                   bukrs    = t_tx03-bukrs
                                   brnch    = t_tx03-brnch
**End of modification
                                   fptwo(3) = t_tx03-fakturno+6(3)
                                   TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      CLEAR ld_ok.
    ENDIF.
  ENDIF.

  CHECK ld_ok EQ space.

  IF t_tx03-wapu NE space.
    IF t_tx03-wapu EQ c_wapu_w.
      t_tx04_upd-ppnwapu_cab = t_tx03-fakppn.
      t_tx04_upd-ppnbmwapu_cab = t_tx03-fakppnbm.
    ENDIF.
  ENDIF.

  IF ( t_tx03-form EQ c_form_a2 AND t_tx03-flaga2 EQ c_flaga2_a ).
    t_tx04_upd-ppntang_cab   = t_tx03-fakppn.
    t_tx04_upd-ppnbmtang_cab = t_tx03-fakppnbm.
  ENDIF.

  IF ( t_tx03-form EQ c_form_a2 AND t_tx03-flaga2 EQ c_flaga2_d ).
    t_tx04_upd-ppnbas_cab   = t_tx03-fakppn.
    t_tx04_upd-ppnbmbas_cab = t_tx03-fakppnbm.
  ENDIF.

  t_tx04_upd-ppnotstd_cab = t_tx03-fakppn.
  t_tx04_upd-ppnbm_cab    = t_tx03-fakppnbm.
  t_tx04_upd-waers   = t_tx03-waerk.  "added by Rahmadi 05/03/2004
  COLLECT t_tx04_upd.

ENDFORM.                    " F_COLLECT_FROM03_CAB

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_FROM02_CAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_from02_cab.

  CASE t_tx02-ptype.
    WHEN c_type_n.
*      IF ( t_tx02-fakturno EQ space AND t_tx02-wapu NE c_wapu_w ).
      IF t_tx02-fakturno EQ space.
        t_tx04_upd-ppnotsda_cab = t_tx02-ppnlast.
        t_tx04_upd-ppnbmsda_cab = t_tx02-ppnbmlast.
      ENDIF.
    WHEN c_type_r OR
****added for MKM by Rahmadi 08/03/2004
         c_type_p.
      IF NOT t_tx02-noretur IS INITIAL.
        t_tx04_upd-ppnretur_cab = t_tx02-ppnlast.  "original code
      ELSE.
        CLEAR t_tx04_upd-ppnretur_cab.
      ENDIF.
****end of addition
  ENDCASE.
  t_tx04_upd-waers   = t_tx02-waers.  "added by Rahmadi 05/03/2004
  COLLECT t_tx04_upd.

ENDFORM.                    " F_COLLECT_FROM02_CAB

*&---------------------------------------------------------------------*
*&      Form  F_GET_CABS_TX05
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_cabs_tx05.
  CLEAR : t_cab_tx05,t_cab_tx05[].

  CHECK NOT t_tx04_upd[] IS INITIAL.

*  SELECT vkorg     gsber
*         masafrom  fptwo
*  FROM zGDTXdt0005
*  INTO TABLE t_cab_tx05
*  FOR ALL ENTRIES IN t_tx04_upd
*  WHERE vkorg EQ t_tx04_upd-vkorg
*    AND gsber EQ t_tx04_upd-gsber.
*
*  SORT t_cab_tx05 BY vkorg gsber masafrom DESCENDING.
*  DELETE ADJACENT DUPLICATES FROM t_cab_tx05
*  COMPARING vkorg gsber masafrom.
*  SORT t_cab_tx05 BY vkorg gsber.

  SELECT
         bukrs     brnch
         masafrom  fptwo
         vkorg     gsber
  FROM zgdtxdt0005
  INTO CORRESPONDING FIELDS OF TABLE t_cab_tx05
  FOR ALL ENTRIES IN t_tx04_upd
  WHERE
***modified by Rahmadi
*        vkorg EQ t_tx04_upd-vkorg
*    AND gsber EQ t_tx04_upd-gsber.
        bukrs EQ t_tx04_upd-bukrs
    AND brnch EQ t_tx04_upd-brnch.
***end of modification

ENDFORM.                    " F_GET_CABS_TX05

*&---------------------------------------------------------------------*
*&      Form  F_CAB_COLLECT_TX04_UPD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cab_7012_collect_tx04_upd.
  DATA lt_tx04_upd LIKE t_tx04_upd.

  LOOP AT t_tx04_upd.
    lt_tx04_upd = t_tx04_upd.
*---tx12
**** Modified by Rahmadi
*    IF t_tx04_upd-gsber+1(3) NE c_gsber_pusat+1(3).
*      LOOP AT t_tx12 WHERE bukrs  = lt_tx04_upd-vkorg
*                       AND gsber  = lt_tx04_upd-gsber
*                       AND masatx = lt_tx04_upd-masatx.
    IF t_tx04_upd-brnch NE d_ho_brnch.
      LOOP AT t_tx12 WHERE bukrs  = lt_tx04_upd-bukrs
                       AND brnch  = lt_tx04_upd-brnch
                       AND masatx = lt_tx04_upd-masatx.
**** End of modification
        PERFORM f_clear_tx04_upd USING lt_tx04_upd.
        PERFORM f_collect_from12.
      ENDLOOP.
    ENDIF.
*---tx03
**** Modified by Rahmadi
*    LOOP AT t_tx03 WHERE vkorg  = lt_tx04_upd-vkorg
*                     AND gsber  = lt_tx04_upd-gsber
*                     AND masatx = lt_tx04_upd-masatx.
    LOOP AT t_tx03 WHERE bukrs  = lt_tx04_upd-bukrs
                     AND brnch  = lt_tx04_upd-brnch
                     AND masatx = lt_tx04_upd-masatx.
**** End of modification
      PERFORM f_clear_tx04_upd USING lt_tx04_upd.
      PERFORM f_collect_from03_cab.
**** Modified by Rahmadi
*      IF t_tx04_upd-gsber+1(3) NE c_gsber_pusat+1(3).
      IF t_tx04_upd-brnch NE d_ho_brnch.
**** End of modification
        PERFORM f_clear_tx04_upd USING lt_tx04_upd.
        PERFORM f_collect_from03.
      ENDIF.
    ENDLOOP.
*---tx02
    LOOP AT t_tx02 WHERE
**** Modified by Rahmadi
*                         vkorg  = lt_tx04_upd-vkorg
*                     AND gsber  = lt_tx04_upd-gsber
                         bukrs  = lt_tx04_upd-bukrs
                     AND brnch  = lt_tx04_upd-brnch
**** End of modification
                     AND masatx = lt_tx04_upd-masatx.

***Modified by Rahmadi
      CLEAR t_fkart09.
      READ TABLE t_fkart09 WITH KEY fkart = t_tx02-fkart BINARY SEARCH.
      t_tx02-ptype = t_fkart09-ptype.
      MODIFY t_tx02.
**** End of modification

      PERFORM f_clear_tx04_upd USING lt_tx04_upd.
      PERFORM f_collect_from02_cab.
**** Modified by Rahmadi
*      IF t_tx04_upd-gsber+1(3) NE c_gsber_pusat+1(3).
      IF t_tx04_upd-brnch NE d_ho_brnch.
**** End of modification
        PERFORM f_clear_tx04_upd USING lt_tx04_upd.
        PERFORM f_collect_from02.
      ENDIF.
    ENDLOOP.
  ENDLOOP.


ENDFORM.                    " F_CAB_COLLECT_TX04_UPD

*&---------------------------------------------------------------------*
*&      Form  F_CAB_7012_NON_DKI
*&---------------------------------------------------------------------*
*---sederhana jasa cabang (ZRIN, fakturno ='',spart='03')
*---standard jasa cabang yg make NPWP pusat (ZRIN, fakturno ='',
*   spart='03', NPWP = NPWP pusat)
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cab_7012_non_dki.
*  CLEAR : t_tx04_ndki,t_tx04_ndki[].

*-get npwp pusat
  PERFORM f_cab_7012_npwp_pusat.


*-non DKI PPNOTSDA
  PERFORM f_cab_7012_nondki_ppnotsda.
*-non DKI PPNOTSDA_CAB
  PERFORM f_cab_7012_nondki_ppnotsda_cab.

*-non DKI PPNOTSTD & PPNWAPU
  PERFORM f_cab_7012_nondki_ppnotstd.
*-non DKI PPNOTSTD_CAB & PPNWAPU_CAB
  PERFORM f_cab_7012_nondki_ppnotstd_cab.

ENDFORM.                    " F_CAB_7012_NON_DKI


*&---------------------------------------------------------------------

*&      Form  F_PUSAT_7022_TX05
*&---------------------------------------------------------------------

*7       text
*----------------------------------------------------------------------

*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------
FORM f_pusat_7022_tx05.

*  SELECT vkorg    gsber
*         masafrom fptwo
*  FROM zGDTXdt0005
*  INTO TABLE t_pusat_tx05
*  WHERE vkorg EQ   p_vkorg
*    AND gsber LIKE c_gsber_pusat.
*
*  SORT t_pusat_tx05 BY vkorg gsber masafrom DESCENDING.
*  DELETE ADJACENT DUPLICATES FROM t_pusat_tx05 COMPARING vkorg gsber.

  SELECT vkorg    gsber
         bukrs    brnch
         masafrom fptwo
  FROM zgdtxdt0005
  INTO CORRESPONDING FIELDS OF TABLE t_pusat_tx05
***modified by Rahmadi
  FOR ALL ENTRIES IN t_ho
  WHERE
*        vkorg EQ   p_vkorg
*    AND gsber LIKE c_gsber_pusat.
        bukrs EQ   p_bukrs
    AND brnch = t_ho-brnch.
***end of modification

ENDFORM.                    " F_PUSAT_7022_TX05

*&---------------------------------------------------------------------*
*&      Form  F_PUSAT_7024_TX04_DATA_NONDKI
*&---------------------------------------------------------------------*
*  A NON DKI gsber sederhana tax value = a.
* a : cumulative TX02-ppnlast with pstyv=ZRIN for that gsber
*
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pusat_7024_tx04_data_nondki.
  PERFORM f_pusat_7024_tx05_pusat.

*-non DKI PPNOTSDA
  PERFORM f_pst_ndki_gsbers_ppnotsda.
*-non DKI PPNOTSDA_CAB
  PERFORM f_pst_ndki_gsbers_ppnotsda_cab.

*-non DKI PPNOTSTD & PPNWAPU
  PERFORM f_pst_ndki_gsbers_ppnotstd.
*-non DKI PPNOTSTD_CAB & PPNWAPU_CAB
  PERFORM f_pst_ndki_gsbers_ppnotstd_cab.

ENDFORM.                    " F_PUSAT_7024_TX04_DATA_NONDKI

*&---------------------------------------------------------------------*
*&      Form  F_NAS_NDKI_TAXAMOUNT
*&---------------------------------------------------------------------*
*       same as f_pusat_7024_tx04_data_nondki form
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_nas_ndki_taxamount_gsbers.
*-get npwp pusat
  PERFORM f_nas_npwp_pusats.

*-get non dki ppn amount
  PERFORM f_nas_ndki_collect_gsbers.


ENDFORM.                    " F_NAS_NDKI_TAXAMOUNT

*&---------------------------------------------------------------------*
*&      Form  F_NAS_CLOSECREATE_GSBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_nas_closecreate_gsbers.
  DATA lt_tx04_upd LIKE t_tx04_upd OCCURS 0 WITH HEADER LINE.
  CLEAR : t_tx04_upd,t_tx04_upd[].

  IF d_simu = 'X'.
    SELECT *
    FROM zgdtxdt0004
    INTO TABLE t_tx04_upd
    FOR ALL ENTRIES IN t_tx04_p  "t_tx04_p contains all pusat's branches
    WHERE
***modified by Rahmadi
*          vkorg    EQ t_tx04_p-vkorg
          bukrs    EQ t_tx04_p-bukrs
***end of modification
      AND masatx   EQ p_masa.
  ELSE.
    CLEAR zgdtxdt0004-closedat.
    SELECT *
    FROM zgdtxdt0004
    INTO TABLE t_tx04_upd
    FOR ALL ENTRIES IN t_tx04_p       "t_tx04_p contents
    WHERE
***modified by Rahmadi
*          vkorg    EQ t_tx04_p-vkorg  "all UNCLOSED pusat's gsber
          bukrs    EQ t_tx04_p-bukrs
***end of modification
      AND masatx   EQ p_masa
      AND closedat EQ zgdtxdt0004-closedat.
  ENDIF.

*-clear initial value (after simulation case ).
  PERFORM f_clear04 TABLES t_tx04_upd.

***added by Rahmadi
  IF d_branch_num > 1.
***end of modification
***modified by Rahmadi
*  DELETE t_tx04_upd WHERE gsber+1(3) EQ c_gsber_pusat+1(3).
*  DELETE t_tx04_upd WHERE gsber+1(3) EQ c_pusat_xxx+1(3).
    LOOP AT t_tx04_upd.
      READ TABLE t_ho WITH KEY brnch = t_tx04_upd-brnch.
      IF sy-subrc = 0.
        DELETE t_tx04_upd.
      ENDIF.
    ENDLOOP.
***end of modification
***added by Rahmadi
  ENDIF.
***end of modification

  IF d_simu <> 'X'.
*---closing date
    READ TABLE t_tx04_upd INDEX 1.
    t_tx04_upd-closedat = sy-datum.
    MODIFY t_tx04_upd TRANSPORTING closedat WHERE closedat IS initial.
  ENDIF.

*-tax amount
  PERFORM f_nas_ccpng_taxamount_gsbers.
  PERFORM f_nas_ndki_taxamount_gsbers.

*-new tax period for all unclosed gsber (excluding pusat)
  IF d_simu NE 'X'.
    lt_tx04_upd[] = t_tx04_upd[].
    LOOP AT lt_tx04_upd.
      CLEAR : t_tx04_upd.
***modified by Rahmadi
*      t_tx04_upd-vkorg   = lt_tx04_upd-vkorg.
*      t_tx04_upd-gsber   = lt_tx04_upd-gsber.
      t_tx04_upd-bukrs   = lt_tx04_upd-bukrs.
      t_tx04_upd-brnch   = lt_tx04_upd-brnch.
***end of modification
      t_tx04_upd-masatx  = p_masan.
      t_tx04_upd-dki     = lt_tx04_upd-dki.
      APPEND t_tx04_upd.
    ENDLOOP.
  ENDIF.

*-userid
  t_tx04_upd-userid = sy-uname.
  MODIFY t_tx04_upd TRANSPORTING userid
  WHERE userid NE sy-uname.

*-Simulation only
*  IF d_simu EQ 'X'.
*    PERFORM f_nas_simulation_only.
*  ENDIF.

  break ibm_rahmadi.

***Save to table ---> should be processed later!!!

***modified by Rahmadi
***keep branch data in internal tables to be saved later together
***with head office data
  t_tx04_upd_brnch[] = t_tx04_upd[].

  break ibm_rahmadi.
**-close current tax period for all unclosed gsber
**-create next   tax period for all unclosed gsber
*  MODIFY zGDTXdt0004  FROM TABLE t_tx04_upd.
*  CHECK ( sy-subrc EQ 0 AND sy-dbcnt NE 0 ).
*  d_clocing_succeeded = 'X'.
**  MESSAGE s000 WITH text-i03.
***end of modification

  CLEAR : lt_tx04_upd,lt_tx04_upd[].

ENDFORM.                    " F_NAS_CLOSECREATE_GSBER

*&---------------------------------------------------------------------*
*&      Form  F_NAS_CLOSECREATE_PUSATS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_nas_closecreate_pusats.
  CLEAR : t_tx04_upd,t_tx04_upd[].

  CHECK NOT t_tx04_p[] IS INITIAL.
  SELECT * FROM zgdtxdt0004
  INTO TABLE t_tx04_pst
  FOR ALL ENTRIES IN t_tx04_p
  WHERE
***modified by Rahmadi
*        vkorg  EQ t_tx04_p-vkorg
        bukrs  EQ t_tx04_p-bukrs
***end of modification
    AND masatx EQ p_masa.

  CHECK NOT t_tx04_pst[] IS INITIAL.

*-All unclosed Pusat tax value
  PERFORM f_nas_pusat_7022_tx04_value.
  PERFORM f_naspst_7022tx04_collvalue.

***removed by Rahmadi
**-New Pusat tax period
*  IF d_simu NE 'X'.
****removed by Rahmadi
**    PERFORM f_nas_7022_tx04_newpusat.
****end of removal
*
****moved by Rahmadi
*    PERFORM f_update_table ON COMMIT.
*    COMMIT WORK AND WAIT.
****end of movement
*  ENDIF.
***end of removal

*-Simulation only
  IF d_simu EQ 'X'.
****added by Rahmadi
    PERFORM f_closing_report.
****end of addition
    PERFORM f_nas_simulation_only.
***moved by Rahmadi
    CHECK d_clocing_succeeded EQ 'X'.
    MESSAGE s000(zab) WITH text-s11.
***end of movement
  ENDIF.

  break ibm_rahmadi.
****removed by Rahmadi
**-Closing process
*  MODIFY zGDTXdt0004  FROM TABLE t_tx04_upd.
*  CHECK ( sy-subrc EQ 0 AND sy-dbcnt NE 0 ).
*  CHECK d_clocing_succeeded EQ 'X'.
*  IF d_simu EQ 'X'.
*    MESSAGE s000(zab) WITH text-s11.
*  ELSE.
*    MESSAGE s000(zab) WITH text-s01.
*  ENDIF.
****end of removal

ENDFORM.                    " F_NAS_CLOSECREATE_PUSATS

*&---------------------------------------------------------------------*
*&      Form  F_PUSAT_7022_TX04_COLLECT_VALU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pusat_7022_tx04_coll_value.

  READ TABLE t_tx04_p INDEX 1.
  CHECK sy-subrc EQ 0.

  t_tx04_upd-mandt    = sy-mandt.
***modified by Rahmadi
*  t_tx04_upd-vkorg    = p_vkorg.
  t_tx04_upd-bukrs    = p_bukrs.
  t_tx04_upd-gsber    = t_tx04_p-gsber.
  t_tx04_upd-brnch    = t_tx04_p-brnch.
  t_tx04_upd-hcompany = t_tx04_p-hcompany.
***end of modification
  t_tx04_upd-masatx   = p_masa.
*  t_tx04_upd-closedat = sy-datum.
  t_tx04_upd-closedat = t_tx04_p-closedat.
  t_tx04_upd-userid   = sy-uname.
  APPEND t_tx04_upd.

*-Pusat PPNOTSTD & PPNWAPU
  PERFORM f_pusat_7022_tx04_ppnotstd.

*-Pusat PPNOTSDA
  PERFORM f_pusat_7022_tx04_ppnotsda.

*-Pusat PPNOTSDA_CAB
  PERFORM f_pusat_7022tx04_ppnotsdacab.

*-Pusat PPNOTSTD_CAB & PPNWAPU_CAB
  PERFORM f_pusat_7022tx04_ppnotstdcab.

*-Pusat others
  PERFORM f_pusat_7022tx04_others.

ENDFORM.                    " F_PUSAT_7022_TX04_COLLECT_VALU

*&---------------------------------------------------------------------*
*&      Form  F_PUSAT_7022_TX04_NEWPUSAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pusat_7022_tx04_newpusat.
  DATA lt_tx04_upd LIKE t_tx04_upd.

*-create new TP for gsber pusat/T000
  READ TABLE t_tx04_upd INDEX 1.
  CHECK sy-subrc EQ 0.
  lt_tx04_upd = t_tx04_upd.

  CLEAR t_tx04_upd.

  t_tx04_upd-vkorg  = lt_tx04_upd-vkorg.
  t_tx04_upd-gsber  = lt_tx04_upd-gsber.
***added by Rahmadi
  t_tx04_upd-bukrs  = lt_tx04_upd-bukrs.
  t_tx04_upd-brnch  = lt_tx04_upd-brnch.
  t_tx04_upd-hcompany  = lt_tx04_upd-hcompany.
***end of addition
  t_tx04_upd-masatx = tn_tx04-masatx.
  t_tx04_upd-dki    = lt_tx04_upd-dki.
  t_tx04_upd-userid = sy-uname.
  APPEND t_tx04_upd.

*-close gsber pusat/TXXX
  READ TABLE t_tx04 WITH KEY
***modified by Rahmadi
*                        vkorg = p_vkorg
*                        gsber+1(3) = c_pusat_xxx+1(3)
                        bukrs = p_bukrs
                        brnch = d_ho_brnch
***end of modification
                        masatx     = p_masa.
  CHECK sy-subrc EQ 0.
  lt_tx04_upd = t_tx04.

  CLEAR t_tx04_upd.
  t_tx04_upd-vkorg    = lt_tx04_upd-vkorg.
  t_tx04_upd-gsber    = lt_tx04_upd-gsber.
***added by Rahmadi
  t_tx04_upd-bukrs    = lt_tx04_upd-bukrs.
  t_tx04_upd-brnch    = lt_tx04_upd-brnch.
  t_tx04_upd-hcompany  = lt_tx04_upd-hcompany.
***end of addition
  t_tx04_upd-masatx   = lt_tx04_upd-masatx.
  t_tx04_upd-closedat = sy-datum.
  t_tx04_upd-userid   = sy-uname.
  APPEND t_tx04_upd.

*-create new TP for gsber pusat/TXXX
  CLEAR t_tx04_upd.
  t_tx04_upd-vkorg    = lt_tx04_upd-vkorg.
  t_tx04_upd-gsber    = lt_tx04_upd-gsber.
***added by Rahmadi
  t_tx04_upd-bukrs    = lt_tx04_upd-bukrs.
  t_tx04_upd-brnch    = lt_tx04_upd-brnch.
  t_tx04_upd-hcompany  = lt_tx04_upd-hcompany.
***end of addition
  t_tx04_upd-masatx   = tn_tx04-masatx.
  t_tx04_upd-userid   = sy-uname.
  APPEND t_tx04_upd.

  CLEAR lt_tx04_upd.
ENDFORM.                    " F_PUSAT_7022_TX04_NEWPUSAT

*&---------------------------------------------------------------------*
*&      Form  F_NAS_7022_TX04_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_nas_pusat_7022_tx04_value.

*-from table 00012,00003,00002
  PERFORM  f_nas_pusat_7022_tx04_value01.
*-from table 00004
  PERFORM  f_nas_pusat_7022_tx04_value02.


ENDFORM.                    " F_NAS_7022_TX04_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_NAS_7022_TX04_COLL_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_naspst_7022tx04_collvalue.

  IF d_simu = 'X'.
    LOOP AT t_tx04_p.
      t_tx04_upd-mandt    = sy-mandt.
***added by Rahmadi
      t_tx04_upd-bukrs    = t_tx04_p-bukrs.
      t_tx04_upd-brnch    = t_tx04_p-brnch.
      t_tx04_upd-hcompany = t_tx04_p-hcompany.
***end of addition
      t_tx04_upd-vkorg    = t_tx04_p-vkorg.
      t_tx04_upd-gsber    = t_tx04_p-gsber.
      t_tx04_upd-masatx   = p_masa.
      t_tx04_upd-closedat = t_tx04_p-closedat.
      t_tx04_upd-userid   = sy-uname.
***added in Tempo -- CURRENCY
      t_tx04_upd-waers   = t_tx04_p-waers.
***end of Tempo addition
      APPEND t_tx04_upd.
    ENDLOOP.
  ELSE.
    LOOP AT t_tx04_p.
      t_tx04_upd-mandt    = sy-mandt.
***added by Rahmadi
      t_tx04_upd-bukrs    = t_tx04_p-bukrs.
      t_tx04_upd-brnch    = t_tx04_p-brnch.
      t_tx04_upd-hcompany = t_tx04_p-hcompany.
***end of addition
      t_tx04_upd-vkorg    = t_tx04_p-vkorg.
      t_tx04_upd-gsber    = t_tx04_p-gsber.
      t_tx04_upd-masatx   = p_masa.
*      t_tx04_upd-closedat = sy-datum.
      t_tx04_upd-closedat = t_tx04_p-closedat.
      t_tx04_upd-userid   = sy-uname.
***added in Tempo -- CURRENCY
      t_tx04_upd-waers   = t_tx04_p-waers.
***end of Tempo addition
      APPEND t_tx04_upd.
    ENDLOOP.
    t_tx04_upd-closedat = sy-datum.
    MODIFY t_tx04_upd TRANSPORTING closedat
    WHERE closedat IS initial.
  ENDIF.

*-Pusat PPNOTSTD & PPNWAPU
  PERFORM f_naspusat_7022_tx04_ppnotstd.

*-Pusat PPNOTSDA
  PERFORM f_naspusat_7022_tx04_ppnotsda.

*-Pusat PPNOTSDA_CAB
  PERFORM f_naspst7022tx04_ppnotsdacab.

*-Pusat PPNOTSTD_CAB & PPNWAPU_CAB
  PERFORM f_naspst7022tx04_ppnotstdcab.

*-Pusat others
  PERFORM f_naspst7022tx04_others.

ENDFORM.                    " F_NAS_7022_TX04_COLL_VALUE


*&---------------------------------------------------------------------*
*&      Form  F_NAS_7022_TX04_NEWPUSAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_nas_7022_tx04_newpusat.
  DATA lt_tx04_upd LIKE t_tx04_upd OCCURS 0 WITH HEADER LINE.

  lt_tx04_upd[] = t_tx04_upd[].

*-create new TP for gsber pusat
  LOOP AT lt_tx04_upd.
    CLEAR t_tx04_upd.
***added by Rahmadi
    t_tx04_upd-bukrs    = lt_tx04_upd-bukrs.
    t_tx04_upd-brnch    = lt_tx04_upd-brnch.
***end of addition
    t_tx04_upd-vkorg  = lt_tx04_upd-vkorg.
    t_tx04_upd-gsber  = lt_tx04_upd-gsber.
    t_tx04_upd-masatx = p_masan.
    t_tx04_upd-userid = sy-uname.
    APPEND t_tx04_upd.
  ENDLOOP.


***comment by Rahmadi - USELESS
**-create new TP for gsber pusat XXX
*  LOOP AT t_tx04_px.
*    CLEAR t_tx04_upd.
***added by Rahmadi
*    t_tx04_upd-bukrs    = t_tx04_px-bukrs.
*    t_tx04_upd-brnch    = t_tx04_px-brnch.
***end of addition
*    t_tx04_upd-vkorg    = t_tx04_px-vkorg.
*    t_tx04_upd-gsber    = t_tx04_px-gsber.
*    t_tx04_upd-masatx   = p_masa.
*    t_tx04_upd-closedat = sy-datum.
*    t_tx04_upd-userid   = sy-uname.
*    APPEND t_tx04_upd.
*
*    CLEAR t_tx04_upd.
*    t_tx04_upd-vkorg    = t_tx04_px-vkorg.
*    t_tx04_upd-gsber    = t_tx04_px-gsber.
*    t_tx04_upd-masatx   = p_masan.
*    t_tx04_upd-userid   = sy-uname.
*    APPEND t_tx04_upd.
*  ENDLOOP.
***end of comment


ENDFORM.                    " F_NAS_7022_TX04_NEWPUSAT

*&---------------------------------------------------------------------*
*&      Form  F_NAS_SIMULATION_ONLY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_nas_simulation_only.

  DELETE t_tx04_upd WHERE masatx = p_masan.
ENDFORM.                    " F_NAS_SIMULATION_ONLY

*&---------------------------------------------------------------------*
*&      Form  F_NAS_CLEAR04_CC_GSBERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_clear04 TABLES ft_04 STRUCTURE t_tx04_upd.
  DATA : lt_04 LIKE t_tx04_upd OCCURS 0 WITH HEADER LINE.

  lt_04[] = ft_04[].
  CLEAR : ft_04,ft_04[].
  LOOP AT lt_04.
    CLEAR ft_04.
*---Added by Rahmadi
    ft_04-bukrs    = lt_04-bukrs.
    ft_04-brnch    = lt_04-brnch.
    ft_04-hcompany = lt_04-hcompany.
*---End of addition
    ft_04-vkorg    = lt_04-vkorg.
    ft_04-gsber    = lt_04-gsber.
    ft_04-masatx   = lt_04-masatx.
    ft_04-closedat = lt_04-closedat.
    ft_04-dki      = lt_04-dki.
    ft_04-userid   = lt_04-userid.
    APPEND ft_04.
  ENDLOOP.

  CLEAR :lt_04,lt_04[].

ENDFORM.                    " F_NAS_CLEAR04_CC_GSBERS

*&---------------------------------------------------------------------*
*&      Form  F_CAB_7012_NPWP_PUSAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_CAB_TX05  text
*----------------------------------------------------------------------*
FORM f_cab_7012_npwp_pusat.

*  SELECT vkorg gsber
*         MAX( masafrom ) fptwo
*  FROM zGDTXdt0005
*  INTO TABLE t_pusat_tx05
*  WHERE vkorg EQ p_vkorg
*    AND gsber LIKE c_gsber_pusat
*  GROUP BY vkorg gsber fptwo.

*  CLEAR t_pusat_tx05.
*  READ TABLE t_pusat_tx05 INDEX 1.
*  SHIFT t_pusat_tx05-fptwo LEFT DELETING LEADING space.

***Modified by Rahmadi
*  SELECT vkorg gsber
*         bukrs brnch
*         masafrom fptwo
*  FROM zGDTXdt0005
*  INTO CORRESPONDING FIELDS OF TABLE t_pusat_tx05
*  WHERE
****Modified by Rahmadi
**        vkorg EQ p_vkorg
**    AND gsber LIKE c_gsber_pusat.
*        bukrs EQ p_bukrs
*    AND brnch = d_ho_brnch.

  PERFORM f_pusat_7022_tx05.
***End of modification

ENDFORM.                    " F_CAB_7012_NPWP_PUSAT

*&---------------------------------------------------------------------*
*&      Form  F_NAS_NPWP_PUSATS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_CAB_TX05  text
*----------------------------------------------------------------------*
*FORM f_nas_npwp_pusats TABLES   ft_cab_tx05 STRUCTURE t_cab_tx05.
FORM f_nas_npwp_pusats.

  CHECK NOT t_tx04_p[] IS INITIAL.

*  SELECT vkorg gsber
*         masafrom fptwo
*  FROM zGDTXdt0005
*  INTO TABLE t_pusat_tx05
*  FOR ALL ENTRIES IN t_tx04_p
*  WHERE vkorg EQ t_tx04_p-vkorg
*    AND gsber EQ t_tx04_p-gsber.
*
*  SORT t_pusat_tx05 BY vkorg gsber masafrom DESCENDING.
*  DELETE ADJACENT DUPLICATES FROM t_pusat_tx05 COMPARING vkorg gsber.

  SELECT vkorg gsber
         bukrs brnch
         masafrom fptwo
  FROM zgdtxdt0005
  INTO CORRESPONDING FIELDS OF TABLE t_pusat_tx05
  FOR ALL ENTRIES IN t_tx04_p
  WHERE
****modified by rahmadi
*        vkorg EQ t_tx04_p-vkorg
*    AND gsber EQ t_tx04_p-gsber.
        bukrs EQ t_tx04_p-bukrs
    AND brnch EQ t_tx04_p-brnch.
****end of modification

ENDFORM.                    " F_NAS_NPWP_PUSATS

*&---------------------------------------------------------------------*
*&      Form  F_NAS_CCPNG_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_nas_ccpng_get_data.
*--PPN-IN (PPN masukan)
  SELECT
            bukrs
            gsber
            brnch
            spart
            busln
            belnr
            budat
            buzei
            gjahr
            fakturno
            fakdat
            masatx
            credit
*            itamt     "changed by Rahmadi 05/03/2004
            fakppn     "changed by Rahmadi 05/03/2004
            waers
  FROM zgdtxdt0012
  INTO CORRESPONDING FIELDS OF TABLE t_tx12
  FOR ALL ENTRIES IN t_tx04_upd
  WHERE
***modified by Rahmadi
*        bukrs    EQ t_tx04_upd-vkorg
*    AND gsber    EQ t_tx04_upd-gsber
        bukrs    EQ t_tx04_upd-bukrs
    AND brnch    EQ t_tx04_upd-brnch
***end of modification
    AND fakturno NE space
    AND masatx   EQ p_masa
    AND credit   IN (c_credit_c,c_credit_i,c_credit_r).

*--PPN-OTSTD (PPN keluaran standard)
*--PPN-WAPU  (PPN keluaran standard WAPU)
  SELECT
              vkorg
              bukrs
              gsber
              brnch
              spart
              busln
              fakturno
              masatx
              batal
              returcount
              fakppn
              fakppnbm
              wapu
              form
              flaga2
              waerk
    FROM zgdtxdt0003
    INTO CORRESPONDING FIELDS OF TABLE t_tx03
    FOR ALL ENTRIES IN t_tx04_upd
    WHERE
****modified by Rahmadi
*          vkorg    EQ t_tx04_upd-vkorg
*      AND gsber    EQ t_tx04_upd-gsber
          bukrs    EQ t_tx04_upd-bukrs
      AND brnch    EQ t_tx04_upd-brnch
****end of modification
      AND fakturno NE space
      AND masatx   EQ p_masa
      AND batal    NE c_batal_x
      AND returcount LT 1.

*--PPN-OTSTD (PPN keluaran standard) V

***modified by Rahmadi
*  SELECT
*              x~vkorg
*              x~bukrs
*              x~gsber
*              x~brnch
*              x~spart
*              x~busln
*              x~vbeln
*              x~posnr
*              x~gjahr
*              x~fakturno
*              x~fkart
*              x~masatx
*              x~ppnlast
*              x~ppnbmlast
*              x~pstyv
*              x~wapu
*              y~ptype
*    FROM zGDTXdt0002 AS x INNER JOIN zGDTXdt0009 AS y
*                       ON x~fkart = y~fkart
*    INTO CORRESPONDING FIELDS OF TABLE t_tx02
*    FOR ALL ENTRIES IN t_tx04_upd
*    WHERE
****modified by Rahmadi
**          x~vkorg    EQ t_tx04_upd-vkorg
**      AND x~gsber    EQ t_tx04_upd-gsber
*          x~bukrs    EQ t_tx04_upd-bukrs
*      AND x~brnch    EQ t_tx04_upd-brnch
****end of modification
*      AND x~masatx   EQ p_masa
*      AND y~ptype    IN (c_type_n,c_type_r,c_type_p).

  PERFORM f_t_tx02 TABLES t_tx02
                          t_tx04_upd
                   USING  'X'.
***end of modification

ENDFORM.                    " F_NAS_CCPNG_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_NAS_CCPNG_GET_TX05
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_nas_ccpng_get_tx05.
  PERFORM f_get_cabs_tx05.

ENDFORM.                    " F_NAS_CCPNG_GET_TX05

*&---------------------------------------------------------------------*
*&      Form  F_NAS_CCPNG_COLL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_nas_ccpng_coll_data.
  DATA lt_tx04_upd LIKE t_tx04_upd.

  LOOP AT t_tx04_upd.
    lt_tx04_upd = t_tx04_upd.

***modified by Rahmadi
*    IF t_tx04_upd-gsber+1(3) NE c_gsber_pusat+1(3).
*      LOOP AT t_tx12 WHERE bukrs  = lt_tx04_upd-vkorg
*                       AND gsber  = lt_tx04_upd-gsber
    IF t_tx04_upd-brnch NE d_ho_brnch.
      LOOP AT t_tx12 WHERE bukrs  = lt_tx04_upd-bukrs
                       AND brnch  = lt_tx04_upd-brnch
***end of modification
                       AND masatx = lt_tx04_upd-masatx.
        PERFORM f_clear_tx04_upd USING lt_tx04_upd.
        PERFORM f_collect_from12.
      ENDLOOP.
    ENDIF.

***modified by Rahmadi
*    LOOP AT t_tx03 WHERE vkorg  = lt_tx04_upd-vkorg
*                     AND gsber  = lt_tx04_upd-gsber
    LOOP AT t_tx03 WHERE bukrs  = lt_tx04_upd-bukrs
                     AND brnch  = lt_tx04_upd-brnch
***end of modification
                     AND masatx = lt_tx04_upd-masatx.
      PERFORM f_clear_tx04_upd USING lt_tx04_upd.
      PERFORM f_collect_from03_cab.

***modified by Rahmadi
*      IF t_tx04_upd-gsber+1(3) NE c_gsber_pusat+1(3).
      IF t_tx04_upd-brnch NE d_ho_brnch.
***end of modification
        PERFORM f_clear_tx04_upd USING lt_tx04_upd.
        PERFORM f_collect_from03.
      ENDIF.
    ENDLOOP.

***modified by Rahmadi
*    LOOP AT t_tx02 WHERE vkorg  = lt_tx04_upd-vkorg
*                     AND gsber  = lt_tx04_upd-gsber
    LOOP AT t_tx02 WHERE bukrs  = lt_tx04_upd-bukrs
                     AND brnch  = lt_tx04_upd-brnch
***end of modification
                     AND masatx = lt_tx04_upd-masatx.
      PERFORM f_clear_tx04_upd USING lt_tx04_upd.
      PERFORM f_collect_from02_cab.

***modified by Rahmadi
*      IF t_tx04_upd-gsber+1(3) NE c_gsber_pusat+1(3).
      IF t_tx04_upd-brnch NE d_ho_brnch.
***end of modification
        PERFORM f_clear_tx04_upd USING lt_tx04_upd.
        PERFORM f_collect_from02.
      ENDIF.
    ENDLOOP.

  ENDLOOP.

ENDFORM.                    " F_NAS_CCPNG_COLL_DATA

*&---------------------------------------------------------------------*
*&      Form  F_NAS_NDKI_COLLECT_GSBERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_nas_ndki_collect_gsbers.

*-non DKI PPNOTSDA
  PERFORM f_nas_ndki_gsbers_ppnotsda.
*-non DKI PPNOTSDA_CAB
  PERFORM f_nas_ndki_gsbers_ppnotsda_cab.

*-non DKI PPNOTSTD & PPNWAPU
  PERFORM f_nas_ndki_gsbers_ppnotstd.
*-non DKI PPNOTSTD_CAB & PPNWAPU_CAB
  PERFORM f_nas_ndki_gsbers_ppnotstd_cab.


ENDFORM.                    " F_NAS_NDKI_COLLECT_GSBERS

*&---------------------------------------------------------------------*
*&      Form  F_NAS_NDKI_GSBERS_PPNOTSDA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_nas_ndki_gsbers_ppnotsda.
*  DATA : ld_index LIKE sy-tabix.
*
*  LOOP AT t_tx04_upd WHERE dki EQ space.
*    ld_index = sy-tabix.
*    CLEAR t_tx04_upd-ppnotsda.
*    LOOP AT t_tx02 WHERE vkorg  = t_tx04_upd-vkorg
*                     AND gsber  = t_tx04_upd-gsber
*                     AND fakturno = ' '
*                     AND pstyv  <> p_zrin
*                     AND ptype  = c_type_n.
*      ADD t_tx02-ppnlast TO t_tx04_upd-ppnotsda.
*    ENDLOOP.
*    MODIFY t_tx04_upd INDEX ld_index TRANSPORTING ppnotsda.
*  ENDLOOP.

*--NON DKI t_tx04_upd-ppnotsda = ld_a - ld_b
  DATA : ld_index LIKE sy-tabix,
         ld_a LIKE t_tx04-ppnotsda,
         ld_b LIKE t_tx04-ppnotsda.

  break ibm_rahmadi.
  LOOP AT t_tx04_upd WHERE dki EQ space.
*****Modified by Rahmadi
*                       AND gsber+1(3) NE c_gsber_pusat+1(3).
*                       AND brnch NE d_ho_brnch.
*****End of modification
    ld_index = sy-tabix.
    CLEAR : t_tx04_upd-ppnotsda,ld_a,ld_b.

****added by Rahmadi
    READ TABLE t_ho WITH KEY brnch = t_tx04_upd-brnch.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.
****end of addition

****Comment: Not sure whether necessary ??? -- Rahmadi
    LOOP AT t_tx02 WHERE
****Modified by Rahmadi
*                         vkorg  = t_tx04_upd-vkorg
*                     AND gsber  = t_tx04_upd-gsber
                         bukrs  = t_tx04_upd-bukrs
                     AND brnch  = t_tx04_upd-brnch
                     AND fakturno = space
****End of modification
                     AND ptype  = c_type_n.
      CASE t_tx02-pstyv.
        WHEN p_zrin.
          READ TABLE t_pusat_tx05
          WITH KEY
****Modified by Rahmadi
*                   vkorg      = t_tx02-vkorg
*                   gsber+1(3) = c_gsber_pusat+1(3)
                   bukrs      = t_tx02-bukrs
*                   brnch      = d_ho_brnch
****End of modification
                   fptwo(3)   = t_tx02-fakturno+6(3)
                   TRANSPORTING NO FIELDS.
          IF sy-subrc EQ 0.
***modified by Rahmadi
            READ TABLE t_ho WITH KEY brnch = t_tx04_upd-brnch
                            TRANSPORTING NO FIELDS.
            IF sy-subrc = 0.
***end of modification
              ADD t_tx02-ppnlast TO ld_b.
            ENDIF.
          ENDIF.
        WHEN OTHERS.
          IF t_tx02-fakturno = ' '.
            ADD t_tx02-ppnlast TO ld_a.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    t_tx04_upd-ppnotsda = ld_a - ld_b.
    MODIFY t_tx04_upd INDEX ld_index TRANSPORTING ppnotsda.
  ENDLOOP.
****End of comment

ENDFORM.                    " F_NAS_NDKI_GSBERS_PPNOTSDA

*&---------------------------------------------------------------------*
*&      Form  F_NAS_NDKI_GSBERS_PPNOTSDA_CAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_nas_ndki_gsbers_ppnotsda_cab.

  DATA : ld_index LIKE sy-tabix,
         ld_ndki_a LIKE t_tx04_upd-ppnotsda,
         ld_ndki_b LIKE t_tx04_upd-ppnotsda.

  LOOP AT t_tx04_upd WHERE dki EQ space.
****Modified by Rahmadi
*                       AND gsber+1(3) NE c_gsber_pusat+1(3).
*                       AND brnch NE d_ho_brnch.
****End of modification
    ld_index = sy-tabix.
    CLEAR : ld_ndki_a,ld_ndki_b.

****added by Rahmadi
    READ TABLE t_ho WITH KEY brnch = t_tx04_upd-brnch
                    TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.
****end of addition

****Comment: Rahmadi - Not sure whether necessary??
    LOOP AT t_tx02 WHERE
****Modified by Rahmadi
*                         vkorg  = t_tx04_upd-vkorg
*                     AND gsber  = t_tx04_upd-gsber
                         bukrs  = t_tx04_upd-bukrs
                     AND brnch  = t_tx04_upd-brnch
****End of modification
                     AND pstyv  = p_zrin
                     AND ptype  = c_type_n.
      IF t_tx02-fakturno = ' '.
        ADD t_tx02-ppnlast TO ld_ndki_a.
      ELSE.
*-tx05 ok
        READ TABLE t_pusat_tx05 WITH KEY
****Modified by Rahmadi
*                                    vkorg = t_tx02-vkorg
*                                    gsber+1(3) = c_gsber_pusat+1(3)
                                    bukrs = t_tx02-bukrs
*                                    brnch = d_ho_brnch
****End of modification
                                    fptwo(3)   = t_tx02-fakturno+6(3)
                                    TRANSPORTING NO FIELDS.
        IF sy-subrc EQ 0.
****added by Rahmadi
          READ TABLE t_ho WITH KEY brnch = t_tx02-brnch
                          TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
****end of addition
            ADD t_tx02-ppnlast TO ld_ndki_b.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
    t_tx04_upd-ppnotsda_cab   = ld_ndki_a + ld_ndki_b.
    MODIFY t_tx04_upd INDEX ld_index TRANSPORTING ppnotsda_cab.
  ENDLOOP.
****End of comment

ENDFORM.                    " F_NAS_NDKI_GSBERS_PPNOTSDA_CAB

*&---------------------------------------------------------------------*
*&      Form  F_NAS_NDKI_GSBERS_PPNOTSTD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_nas_ndki_gsbers_ppnotstd.

  DATA : ld_index LIKE sy-tabix.

*  LOOP AT t_tx04_upd WHERE dki EQ space.
*    ld_index = sy-tabix.
*    CLEAR : t_tx04_upd-ppnotstd,t_tx04_upd-ppnwapu.
*    READ TABLE t_pusat_tx05 WITH KEY vkorg = t_tx04_upd-vkorg
*                                gsber+1(3) = c_gsber_pusat+1(3).
*    IF sy-subrc EQ 0.
*      LOOP AT t_tx03 WHERE vkorg  = t_tx04_upd-vkorg
*                       AND gsber  = t_tx04_upd-gsber
*                       AND fakturno+6(3) = t_pusat_tx05-fptwo(3).
*        ADD t_tx03-fakppn TO t_tx04_upd-ppnotstd.
*        IF t_tx03-wapu = c_wapu_w.
*          ADD t_tx03-fakppn TO t_tx04_upd-ppnwapu.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
*    MODIFY t_tx04_upd INDEX ld_index TRANSPORTING ppnotstd ppnwapu.
*  ENDLOOP.

  LOOP AT t_tx04_upd WHERE dki EQ space.
****Modified by Rahmadi
*                       AND gsber+1(3) NE c_gsber_pusat+1(3).
*                       AND brnch NE d_ho_brnch.
****End of modification
    ld_index = sy-tabix.
    CLEAR : t_tx04_upd-ppnotstd,t_tx04_upd-ppnwapu.

****added by Rahmadi
    READ TABLE t_ho WITH KEY brnch = t_tx04_upd-brnch
                    TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.
****end of addition


*tx05 ok
    LOOP AT t_tx03 WHERE
****Modified by Rahmadi
*                         vkorg  = t_tx04_upd-vkorg
*                     AND gsber  = t_tx04_upd-gsber.
                         bukrs  = t_tx04_upd-bukrs
                     AND brnch  = t_tx04_upd-brnch.
****End of modification
      READ TABLE t_pusat_tx05 WITH KEY
****Modified by Rahmadi
*                                  vkorg = t_tx03-vkorg
*                                  gsber+1(3) = c_gsber_pusat+1(3)
                                  bukrs = t_tx03-bukrs
*                                  brnch = d_ho_brnch
****End of modification
                                  fptwo(3)   = t_tx03-fakturno+6(3)
                                  TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.
***added by Rahmadi
        READ TABLE t_ho WITH KEY brnch = t_tx04_upd-brnch
                        TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
***end of addition
          ADD t_tx03-fakppn TO t_tx04_upd-ppnotstd.
          IF t_tx03-wapu = c_wapu_w.
            ADD t_tx03-fakppn TO t_tx04_upd-ppnwapu.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
    MODIFY t_tx04_upd INDEX ld_index TRANSPORTING ppnotstd ppnwapu.
  ENDLOOP.

ENDFORM.                    " F_NAS_NDKI_GSBERS_PPNOTSTD

*&---------------------------------------------------------------------*
*&      Form  F_NAS_NDKI_GSBERS_PPNOTSTD_CAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FT_PUSAT_TX05  text
*----------------------------------------------------------------------*
FORM f_nas_ndki_gsbers_ppnotstd_cab.
  DATA : ld_index LIKE sy-tabix.

*  LOOP AT t_tx04_upd WHERE dki EQ space.
*    ld_index = sy-tabix.
*    CLEAR : t_tx04_upd-ppnotstd_cab,t_tx04_upd-ppnwapu_cab.
*
*    READ TABLE t_cab_tx05 WITH KEY vkorg = t_tx04_upd-vkorg
*                                   gsber = t_tx04_upd-gsber.
*    IF sy-subrc EQ 0.
*      LOOP AT t_tx03 WHERE vkorg  = t_tx04_upd-vkorg
*                       AND gsber  = t_tx04_upd-gsber
*                       AND fakturno+6(3) = t_cab_tx05-fptwo(3).
*        ADD t_tx03-fakppn TO t_tx04_upd-ppnotstd_cab.
*        IF t_tx03-wapu = c_wapu_w.
*          ADD t_tx03-fakppn TO t_tx04_upd-ppnwapu_cab.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
*    MODIFY t_tx04_upd INDEX ld_index
*    TRANSPORTING ppnotstd_cab ppnwapu_cab.
*  ENDLOOP.


*tx05 ok

  LOOP AT t_tx04_upd WHERE dki EQ space.
****Modified by Rahmadi
*                       AND gsber+1(3) NE c_gsber_pusat+1(3).
****End of modification
    ld_index = sy-tabix.
    CLEAR : t_tx04_upd-ppnotstd_cab,t_tx04_upd-ppnwapu_cab.

***added by Rahmadi
    READ TABLE t_ho WITH KEY brnch = t_tx04_upd-brnch
                    TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.
***end of addition

    LOOP AT t_tx03 WHERE
****Modified by Rahmadi
*                         vkorg  = t_tx04_upd-vkorg
*                     AND gsber  = t_tx04_upd-gsber.
                         bukrs  = t_tx04_upd-bukrs
                     AND brnch  = t_tx04_upd-brnch.
****End of modification
      READ TABLE t_cab_tx05 WITH KEY
****Modified by Rahmadi
*                                     vkorg    = t_tx04_upd-vkorg
*                                     gsber    = t_tx04_upd-gsber
                                     bukrs    = t_tx04_upd-bukrs
                                     brnch    = t_tx04_upd-brnch
****End of modification
                                     fptwo(3) = t_tx03-fakturno+6(3)
                                     TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.
        ADD t_tx03-fakppn TO t_tx04_upd-ppnotstd_cab.
        IF t_tx03-wapu = c_wapu_w.
          ADD t_tx03-fakppn TO t_tx04_upd-ppnwapu_cab.
        ENDIF.
      ENDIF.
    ENDLOOP.
    MODIFY t_tx04_upd INDEX ld_index
    TRANSPORTING ppnotstd_cab ppnwapu_cab.
  ENDLOOP.


ENDFORM.                    " F_NAS_NDKI_GSBERS_PPNOTSTD_CAB

*&---------------------------------------------------------------------*
*&      Form  F_NASPUSAT_7022_TX04_VALUE01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_nas_pusat_7022_tx04_value01.
*--PPN-IN (PPN masukan)
  SELECT
            bukrs
            gsber
            brnch
            spart
            busln
            belnr
            budat
            buzei
            gjahr
            fakturno
            fakdat
            masatx
            credit
*            itamt     "changed by Rahmadi 05/03/2004
            fakppn     "changed by Rahmadi 05/03/2004
            waers
  FROM zgdtxdt0012
  INTO CORRESPONDING FIELDS OF TABLE t_tx12
  FOR ALL ENTRIES IN t_tx04_pst
  WHERE
***modified by Rahmadi
*        bukrs    EQ t_tx04_pst-vkorg
*    AND gsber    EQ t_tx04_pst-gsber
        bukrs    EQ t_tx04_pst-bukrs
    AND brnch    EQ t_tx04_pst-brnch
***end of modification
*    AND spart    NE space
*    AND gjahr    NE space
    AND fakturno NE space
    AND masatx   EQ p_masa
    AND credit   IN (c_credit_c,c_credit_i,c_credit_r).

*--PPN-OTSTD (PPN keluaran standard)
*--PPN-WAPU  (PPN keluaran standard WAPU)
  SELECT
              vkorg
              bukrs
              gsber
              brnch
              spart
              busln
              fakturno
              masatx
              batal
              returcount
              fakppn
              fakppnbm
              wapu
              form
              flaga2
              waerk
    FROM zgdtxdt0003
    INTO CORRESPONDING FIELDS OF TABLE t_tx03
    FOR ALL ENTRIES IN t_tx04_pst
    WHERE
***modified by Rahmadi
*          vkorg      EQ t_tx04_pst-vkorg
*      AND gsber      EQ t_tx04_pst-gsber
          bukrs      EQ t_tx04_pst-bukrs
      AND brnch      EQ t_tx04_pst-brnch
***end of modification
*      AND spart      NE space
      AND fakturno   NE space
      AND masatx     EQ p_masa
      AND batal      NE c_batal_x
      AND returcount LT 1.

*--PPN-OTSTD (PPN keluaran standard)
*--PPN-OTSDA (PPN keluaran sederhana)
****modified by Rahmadi
*  SELECT
*              x~vkorg
*              x~bukrs
*              x~gsber
*              x~brnch
*              x~spart
*              x~busln
*              x~vbeln
*              x~posnr
*              x~gjahr
*              x~fakturno
*              x~fkart
*              x~masatx
*              x~ppnlast
*              x~ppnbmlast
*              x~pstyv
*              x~wapu
*              y~ptype
*    FROM zGDTXdt0002 AS x INNER JOIN zGDTXdt0009 AS y
*                       ON x~fkart = y~fkart
*    INTO CORRESPONDING FIELDS OF TABLE t_tx02
*    FOR ALL ENTRIES IN t_tx04_pst
*    WHERE
****modified by Rahmadi
**          x~vkorg    EQ t_tx04_pst-vkorg
**      AND x~gsber    EQ t_tx04_pst-gsber
*          x~bukrs    EQ t_tx04_pst-bukrs
*      AND x~brnch    EQ t_tx04_pst-brnch
****end of modification
*      AND x~masatx   EQ p_masa
*      AND y~ptype    IN (c_type_n,c_type_r,c_type_p).

  PERFORM f_t_tx02 TABLES t_tx02
                          t_tx04_pst
                   USING  'X'.
****end of modification

ENDFORM.                    " F_NASPUSAT_7022_TX04_VALUE01

*&---------------------------------------------------------------------*
*&      Form  F_NAS_PUSAT_7022_TX04_VALUE02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_nas_pusat_7022_tx04_value02.

*-Get all branches belonging to all selected head offices
  SELECT * FROM zgdtxdt0004
  INTO TABLE t_tx04_gsbers
  FOR ALL ENTRIES IN t_tx04_p
  WHERE
***modified by Rahmadi
*        vkorg   EQ t_tx04_p-vkorg
*    AND gsber   NE space
        bukrs   EQ t_tx04_p-bukrs
    AND brnch   NE space
***end of modification
    AND masatx  EQ p_masa.

***modified by Rahmadi
*  DELETE t_tx04_gsbers WHERE gsber+1(3) EQ c_gsber_pusat+1(3).
*  DELETE t_tx04_gsbers WHERE gsber+1(3) EQ c_pusat_xxx+1(3).
  IF d_branch_num > 1 AND
     NOT t_branch[] IS INITIAL.
    LOOP AT t_tx04_gsbers.
      READ TABLE t_ho WITH KEY brnch = t_tx04_gsbers-brnch
                      TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        DELETE t_tx04_gsbers.
      ENDIF.
    ENDLOOP.
  ENDIF.
***end of modification
ENDFORM.                    " F_NAS_PUSAT_7022_TX04_VALUE02

*&---------------------------------------------------------------------*
*&      Form  F_NAS_7022_TX04_PPNOTSTD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_naspusat_7022_tx04_ppnotstd.
  DATA :
*         lt_tx04_upd LIKE t_tx04_upd,
  ld_index LIKE sy-tabix,
  ld_a  LIKE t_tx04_upd-ppnotstd,
  ld_b  LIKE t_tx04_upd-ppnotstd,
  ld_aw LIKE t_tx04_upd-ppnotstd,
  ld_bw LIKE t_tx04_upd-ppnotstd.

*  LOOP AT t_tx04_upd.
*    lt_tx04_upd = t_tx04_upd.
*    LOOP AT t_tx04_gsbers WHERE vkorg EQ t_tx04_upd-vkorg.
*      PERFORM f_clear_tx04_upd USING lt_tx04_upd.
*      t_tx04_upd-ppnotstd = t_tx04_gsbers-ppnotstd.
*      t_tx04_upd-ppnwapu  = t_tx04_gsbers-ppnwapu.
*      COLLECT t_tx04_upd.
*    ENDLOOP.
*  ENDLOOP.

  LOOP AT t_tx04_upd.
    ld_index = sy-tabix.
    CLEAR : ld_a,ld_b,ld_aw,ld_bw.
***modified by Rahmadi
*    LOOP AT t_tx04_gsbers WHERE vkorg EQ t_tx04_upd-vkorg.
    LOOP AT t_tx04_gsbers WHERE bukrs EQ t_tx04_upd-bukrs.
***end of modification
      ADD t_tx04_gsbers-ppnotstd TO ld_a.
      ADD t_tx04_gsbers-ppnwapu  TO ld_aw.
    ENDLOOP.

***modified by Rahmadi
*    LOOP AT t_tx03 WHERE vkorg  = t_tx04_upd-vkorg
*                     AND gsber  = t_tx04_upd-gsber
    LOOP AT t_tx03 WHERE bukrs  = t_tx04_upd-bukrs
                     AND brnch  = t_tx04_upd-brnch
***end of modification
                     AND masatx = t_tx04_upd-masatx.
      READ TABLE t_pusat_tx05 WITH KEY
***modified by Rahmadi
*                                       vkorg = t_tx03-vkorg
*                                       gsber = t_tx03-gsber
                                       bukrs = t_tx03-bukrs
                                       brnch = t_tx03-brnch
***end of modification
                                       fptwo(3) = t_tx03-fakturno+6(3)
                                       TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.
        ADD t_tx03-fakppn TO ld_b.
        IF t_tx03-wapu EQ c_wapu_w.
          ADD t_tx03-fakppn TO ld_bw.
        ENDIF.
      ENDIF.
    ENDLOOP.

    t_tx04_upd-ppnotstd = ld_a  + ld_b.
    t_tx04_upd-ppnwapu  = ld_aw + ld_bw.
    t_tx04_upd-waers = t_tx03-waerk.     "added by Rahmadi 05/03/2004

    IF t_tx04_upd-ppnotstd <> 0 OR
       t_tx04_upd-ppnwapu <> 0.       "added for bugfix at Tempo
      MODIFY t_tx04_upd INDEX ld_index TRANSPORTING ppnotstd ppnwapu
                                                    waers.
    ELSE.
      CLEAR t_tx04_upd.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  CLEAR : ld_index ,
  ld_a,
  ld_b,
  ld_aw,
  ld_bw.

ENDFORM.                    " F_NAS_7022_TX04_PPNOTSTD

*&---------------------------------------------------------------------*
*&      Form  F_NASPUSAT_7022_TX04_PPNOTSDA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_naspusat_7022_tx04_ppnotsda.
  DATA : lt_tx04_upd LIKE t_tx04_upd,
         ld_b LIKE t_tx04_upd-ppnotsda,
         ld_p LIKE t_tx04_upd-ppnotsda,
         ld_index LIKE sy-tabix.

**-t_tx04_upd-ppnotsda = ld_a + ld_p - ld_b.

*-ld_a
  LOOP AT t_tx04_upd.
    lt_tx04_upd = t_tx04_upd.

***modified by rahmadi
*    LOOP AT t_tx04_gsbers WHERE vkorg EQ t_tx04_upd-vkorg.
    LOOP AT t_tx04_gsbers WHERE bukrs EQ t_tx04_upd-bukrs.
***end of modification
      PERFORM f_clear_tx04_upd USING lt_tx04_upd.
      t_tx04_upd-ppnotsda = t_tx04_gsbers-ppnotsda.
      COLLECT t_tx04_upd.
    ENDLOOP.
  ENDLOOP.

*-ld_p
  LOOP AT t_tx04_upd.
    lt_tx04_upd = t_tx04_upd.
***modified by rahmadi
*    LOOP AT t_tx02 WHERE vkorg  = t_tx04_upd-vkorg
*                     AND gsber  = t_tx04_upd-gsber
    LOOP AT t_tx02 WHERE bukrs  = t_tx04_upd-bukrs
                     AND brnch  = t_tx04_upd-brnch
***end of modification
                     AND masatx = t_tx04_upd-masatx
                     AND fakturno = ' '
                     AND ptype  = c_type_n.
*      READ TABLE t_pusat_tx05 WITH KEY vkorg   = t_tx02-vkorg
*                                       gsber   = t_tx02-gsber
*                                      fptwo(3) = t_tx02-fakturno+6(3)
*                                      TRANSPORTING NO FIELDS.
*      IF sy-subrc EQ 0.
      PERFORM f_clear_tx04_upd USING lt_tx04_upd.
      t_tx04_upd-ppnotsda = t_tx02-ppnlast.
      t_tx04_upd-waers = t_tx02-waers.     "added by Rahmadi 05/03/2004
      COLLECT t_tx04_upd.
*      ENDIF.
    ENDLOOP.

  ENDLOOP.


*  LOOP AT t_tx04_upd.
*    ld_index = sy-tabix.
*    CLEAR ld_b.
*
*    READ TABLE t_pusat_tx05 WITH KEY vkorg = t_tx04_upd-vkorg
*                                     gsber = t_tx04_upd-gsber.
*    IF sy-subrc EQ 0.
*      LOOP AT t_tx02 WHERE vkorg    EQ t_tx04_upd-vkorg
*                       AND fakturno+6(3) = t_pusat_tx05-fptwo(3)
*                       AND pstyv    EQ p_zrin
*                       AND ptype    EQ c_type_n.
*        READ TABLE t_tx04_gsbers WITH KEY vkorg = t_tx02-vkorg
*                                          gsber = t_tx02-gsber
*                                          dki   = ' '.
*        IF sy-subrc EQ 0.
*          ADD t_tx02-ppnlast TO ld_b.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
*    t_tx04_upd-ppnotsda = t_tx04_upd-ppnotsda - ld_b.
*    MODIFY t_tx04_upd INDEX ld_index TRANSPORTING ppnotsda.
*  ENDLOOP.

***removed by Rahmadi --- NOT GENERAL
*  LOOP AT t_tx04_upd.
*    ld_index = sy-tabix.
*    CLEAR ld_b.
****modified by rahmadi
**    LOOP AT t_tx02 WHERE vkorg    EQ t_tx04_upd-vkorg
*    LOOP AT t_tx02 WHERE bukrs    EQ t_tx04_upd-bukrs
**                     AND pstyv    EQ p_zrin    "need to investigate!!!
****end of modification
*                     AND ptype    EQ c_type_n.
****modified by Rahmadi
**      READ TABLE t_tx04_gsbers WITH KEY vkorg = t_tx02-vkorg
**                                        gsber = t_tx02-gsber
*      READ TABLE t_tx04_gsbers WITH KEY bukrs = t_tx02-bukrs
*                                        brnch = t_tx02-brnch
****end of modification
*                                        dki   = ' '.
*      IF sy-subrc EQ 0.
****modified by Rahmadi
**        READ TABLE t_pusat_tx05 WITH KEY vkorg   = t_tx02-vkorg
**                                         gsber   = t_tx02-gsber
*        READ TABLE t_pusat_tx05 WITH KEY bukrs   = t_tx02-bukrs
*                                         brnch   = t_tx02-brnch
****end of modification
*                                        fptwo(3) = t_tx02-fakturno+6(3)
*                                        TRANSPORTING NO FIELDS.
*        IF sy-subrc EQ 0.
*          ADD t_tx02-ppnlast TO ld_b.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*    t_tx04_upd-ppnotsda = t_tx04_upd-ppnotsda - ld_b.
*    MODIFY t_tx04_upd INDEX ld_index TRANSPORTING ppnotsda.
*  ENDLOOP.
****end of removal

  CLEAR: lt_tx04_upd,
         ld_b,
         ld_p,
         ld_index.
ENDFORM.                    " F_NASPUSAT_7022_TX04_PPNOTSDA

*&---------------------------------------------------------------------*
*&      Form  F_NASPUSAT_7022_TX04_PPNOTSDA_
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_naspst7022tx04_ppnotsdacab.
  DATA lt_tx04_upd LIKE t_tx04_upd.

  LOOP AT t_tx04_upd.
    lt_tx04_upd = t_tx04_upd.

***modified by Rahmadi
*    LOOP AT t_tx02 WHERE vkorg    EQ t_tx04_upd-vkorg
*                     AND gsber    EQ t_tx04_upd-gsber
    LOOP AT t_tx02 WHERE bukrs    EQ t_tx04_upd-bukrs
                     AND brnch    EQ t_tx04_upd-brnch
***end of modification
                     AND fakturno EQ space
                     AND ptype    EQ c_type_n.
      PERFORM f_clear_tx04_upd USING lt_tx04_upd.
      t_tx04_upd-ppnotsda_cab = t_tx02-ppnlast.
      COLLECT t_tx04_upd.
    ENDLOOP.
  ENDLOOP.

  CLEAR lt_tx04_upd.

ENDFORM.                    " F_NASPUSAT_7022_TX04_PPNOTSDA_

*&---------------------------------------------------------------------*
*&      Form  F_NASPUSAT_7022_TX04_PPNOTSTD_
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_naspst7022tx04_ppnotstdcab.
  DATA lt_tx04_upd LIKE t_tx04_upd.

*  LOOP AT t_tx04_upd.
*    lt_tx04_upd = t_tx04_upd.
*
*    READ TABLE t_pusat_tx05 WITH KEY vkorg = t_tx04_upd-vkorg
*                                     gsber = t_tx04_upd-gsber.
*    IF sy-subrc EQ 0.
*      LOOP AT t_tx03 WHERE vkorg    EQ t_tx04_upd-vkorg
*                       AND gsber    EQ t_tx04_upd-gsber
*                       AND fakturno+6(3) = t_pusat_tx05-fptwo(3).
*        PERFORM f_clear_tx04_upd USING lt_tx04_upd.
*        t_tx04_upd-ppnotstd_cab = t_tx03-fakppn.
*        IF t_tx03-wapu = c_wapu_w.
*          t_tx04_upd-ppnwapu_cab = t_tx03-fakppn.
*        ENDIF.
*        COLLECT t_tx04_upd.
*      ENDLOOP.
*    ENDIF.
*  ENDLOOP.

  LOOP AT t_tx04_upd.
    lt_tx04_upd = t_tx04_upd.

***modified by Rahmadi
*    LOOP AT t_tx03 WHERE vkorg    EQ t_tx04_upd-vkorg
*                     AND gsber    EQ t_tx04_upd-gsber.
*      READ TABLE t_pusat_tx05 WITH KEY vkorg = t_tx03-vkorg
*                                       gsber = t_tx03-gsber
    LOOP AT t_tx03 WHERE bukrs    EQ t_tx04_upd-bukrs
                     AND brnch    EQ t_tx04_upd-brnch.
      READ TABLE t_pusat_tx05 WITH KEY bukrs = t_tx03-bukrs
                                       brnch = t_tx03-brnch
***end of modification
                                       fptwo(3) = t_tx03-fakturno+6(3).
      IF sy-subrc EQ 0.
        PERFORM f_clear_tx04_upd USING lt_tx04_upd.
        t_tx04_upd-ppnotstd_cab = t_tx03-fakppn.
        IF t_tx03-wapu = c_wapu_w.
          t_tx04_upd-ppnwapu_cab = t_tx03-fakppn.
        ENDIF.
        COLLECT t_tx04_upd.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  CLEAR lt_tx04_upd.

ENDFORM.                    " F_NASPUSAT_7022_TX04_PPNOTSTD_

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_FROM03_PUSAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_from03_pusat.
  IF t_tx03-wapu NE space.
    IF t_tx03-wapu EQ c_wapu_w.
*      t_tx04_upd-ppnwapu = t_tx03-fakppn.
      t_tx04_upd-ppnbmwapu = t_tx03-fakppnbm.
    ENDIF.
  ENDIF.

  IF ( t_tx03-form EQ c_form_a2 AND t_tx03-flaga2 EQ c_flaga2_a ).
    t_tx04_upd-ppntang   = t_tx03-fakppn.
    t_tx04_upd-ppnbmtang = t_tx03-fakppnbm.
  ENDIF.

  IF ( t_tx03-form EQ c_form_a2 AND t_tx03-flaga2 EQ c_flaga2_d ).
    t_tx04_upd-ppnbas   = t_tx03-fakppn.
    t_tx04_upd-ppnbmbas = t_tx03-fakppnbm.
  ENDIF.

*  t_tx04_upd-ppnotstd = t_tx03-fakppn.
  t_tx04_upd-ppnbm    = t_tx03-fakppnbm.
  COLLECT t_tx04_upd.

ENDFORM.                    " F_COLLECT_FROM03_PUSAT

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_FROM03_CAB_PUSAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_from03_cab_pusat.
  IF t_tx03-wapu NE space.
    IF t_tx03-wapu EQ c_wapu_w.
*      t_tx04_upd-ppnwapu_cab = t_tx03-fakppn.
      t_tx04_upd-ppnbmwapu_cab = t_tx03-fakppnbm.
    ENDIF.
  ENDIF.

  IF ( t_tx03-form EQ c_form_a2 AND t_tx03-flaga2 EQ c_flaga2_a ).
    t_tx04_upd-ppntang_cab   = t_tx03-fakppn.
    t_tx04_upd-ppnbmtang_cab = t_tx03-fakppnbm.
  ENDIF.

  IF ( t_tx03-form EQ c_form_a2 AND t_tx03-flaga2 EQ c_flaga2_d ).
    t_tx04_upd-ppnbas_cab   = t_tx03-fakppn.
    t_tx04_upd-ppnbmbas_cab = t_tx03-fakppnbm.
  ENDIF.

*  t_tx04_upd-ppnotstd_cab = t_tx03-fakppn.
  t_tx04_upd-ppnbm_cab    = t_tx03-fakppnbm.
  COLLECT t_tx04_upd.


ENDFORM.                    " F_COLLECT_FROM03_CAB_PUSAT

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_FROM02_CAB_PUSAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_from02_cab_pusat.
  CASE t_tx02-ptype.
    WHEN c_type_n.
*      IF ( t_tx02-fakturno EQ space AND t_tx02-wapu NE c_wapu_w ).
      IF t_tx02-fakturno EQ space.
*        t_tx04_upd-ppnotsda_cab = t_tx02-ppnlast.
        t_tx04_upd-ppnbmsda_cab = t_tx02-ppnbmlast.
      ENDIF.
    WHEN c_type_r OR
****added for MKM by Rahmadi 08/03/2004
         c_type_p.
      IF NOT t_tx02-noretur IS INITIAL.
        t_tx04_upd-ppnretur_cab = t_tx02-ppnlast.  "original code
      ELSE.
        CLEAR t_tx04_upd-ppnretur_cab.
      ENDIF.
****end of addition
  ENDCASE.
  COLLECT t_tx04_upd.


ENDFORM.                    " F_COLLECT_FROM02_CAB_PUSAT

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_FROM02_PUSAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_from02_pusat.
  CASE t_tx02-ptype.
    WHEN c_type_n.
*      IF ( t_tx02-fakturno EQ space AND t_tx02-wapu NE c_wapu_w ).
      IF t_tx02-fakturno EQ space.
*        t_tx04_upd-ppnotsda = t_tx02-ppnlast.
        t_tx04_upd-ppnbmsda = t_tx02-ppnbmlast.
      ENDIF.
    WHEN c_type_r OR
****added for MKM by Rahmadi 08/03/2004
         c_type_p.
      IF NOT t_tx02-noretur IS INITIAL.
        t_tx04_upd-ppnretur = t_tx02-ppnlast.  "original code
      ELSE.
        CLEAR t_tx04_upd-ppnretur.
      ENDIF.
****end of addition
  ENDCASE.
  COLLECT t_tx04_upd.


ENDFORM.                    " F_COLLECT_FROM02_PUSAT

*&---------------------------------------------------------------------*
*&      Form  F_NASPST7022TX04_OTHERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_naspst7022tx04_others.
  DATA lt_tx04_upd LIKE t_tx04_upd.

  LOOP AT t_tx04_upd.
    lt_tx04_upd = t_tx04_upd.

*---tx12
****modified by Rahmadi
*    LOOP AT t_tx12 WHERE bukrs EQ t_tx04_upd-vkorg.
    LOOP AT t_tx12 WHERE bukrs EQ t_tx04_upd-bukrs.
***end of modification
      PERFORM f_clear_tx04_upd USING lt_tx04_upd.
      PERFORM f_collect_from12.
    ENDLOOP.
*---tx03
***modified by Rahmadi
*    LOOP AT t_tx03 WHERE vkorg EQ t_tx04_upd-vkorg.
    LOOP AT t_tx03 WHERE bukrs EQ t_tx04_upd-bukrs.
***end of modification
*      CLEAR t_cab_tx05.
*      READ TABLE t_cab_tx05 WITH KEY vkorg = t_tx03-vkorg
*                                     gsber = t_tx03-gsber.
*      PERFORM f_clear_tx04_upd USING lt_tx04_upd.
*      IF t_tx03-fakturno+6(3) = t_cab_tx05-fptwo(3).
*        PERFORM f_collect_from03_cab_pusat.
*      ELSE.
*        PERFORM f_collect_from03_pusat.
*      ENDIF.
      CLEAR t_cab_tx05.
***modified by Rahmadi
*      READ TABLE t_cab_tx05 WITH KEY vkorg    = t_tx03-vkorg
*                                     gsber    = t_tx03-gsber
      READ TABLE t_cab_tx05 WITH KEY bukrs    = t_tx03-bukrs
                                     brnch    = t_tx03-brnch
***end of modification
                                     fptwo(3) = t_tx03-fakturno+6(3).
      PERFORM f_clear_tx04_upd USING lt_tx04_upd.
      IF t_tx03-fakturno+6(3) = t_cab_tx05-fptwo(3).
        PERFORM f_collect_from03_cab_pusat.
      ELSE.
        PERFORM f_collect_from03_pusat.
      ENDIF.
    ENDLOOP.
*---tx02
    break ibm_rahmadi.
***modified by Rahmadi
*    LOOP AT t_tx02 WHERE vkorg EQ t_tx04_upd-vkorg.
    LOOP AT t_tx02 WHERE bukrs EQ t_tx04_upd-bukrs.
***end of modification
*      CLEAR t_cab_tx05.
*      READ TABLE t_cab_tx05 WITH KEY vkorg = t_tx02-vkorg
*                                     gsber = t_tx02-gsber.
****modified by Rahmadi

      PERFORM f_clear_tx04_upd USING lt_tx04_upd.
      PERFORM f_collect_from02_cab_pusat.
      PERFORM f_clear_tx04_upd USING lt_tx04_upd.
      PERFORM f_collect_from02_pusat.
    ENDLOOP.

  ENDLOOP.

  CLEAR lt_tx04_upd.
ENDFORM.                    " F_NASPST7022TX04_OTHERS

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_FROM03_CAB_GSBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_from03_cab_gsber.
  IF t_tx03-wapu NE space.
    IF t_tx03-wapu EQ c_wapu_w.
*      t_tx04_upd-ppnwapu_cab = t_tx03-fakppn.
      t_tx04_upd-ppnbmwapu_cab = t_tx03-fakppnbm.
    ENDIF.
  ENDIF.

  IF ( t_tx03-form EQ c_form_a2 AND t_tx03-flaga2 EQ c_flaga2_a ).
    t_tx04_upd-ppntang_cab   = t_tx03-fakppn.
    t_tx04_upd-ppnbmtang_cab = t_tx03-fakppnbm.
  ENDIF.

  IF ( t_tx03-form EQ c_form_a2 AND t_tx03-flaga2 EQ c_flaga2_d ).
    t_tx04_upd-ppnbas_cab   = t_tx03-fakppn.
    t_tx04_upd-ppnbmbas_cab = t_tx03-fakppnbm.
  ENDIF.

*  t_tx04_upd-ppnotstd_cab = t_tx03-fakppn.
  t_tx04_upd-ppnbm_cab    = t_tx03-fakppnbm.
  COLLECT t_tx04_upd.

ENDFORM.                    " F_COLLECT_FROM03_CAB_GSBER

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_FROM03_GSBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_from03_gsber.
  IF t_tx03-wapu NE space.
    IF t_tx03-wapu EQ c_wapu_w.
*      t_tx04_upd-ppnwapu = t_tx03-fakppn.
      t_tx04_upd-ppnbmwapu = t_tx03-fakppnbm.
    ENDIF.
  ENDIF.

  IF ( t_tx03-form EQ c_form_a2 AND t_tx03-flaga2 EQ c_flaga2_a ).
    t_tx04_upd-ppntang   = t_tx03-fakppn.
    t_tx04_upd-ppnbmtang = t_tx03-fakppnbm.
  ENDIF.

  IF ( t_tx03-form EQ c_form_a2 AND t_tx03-flaga2 EQ c_flaga2_d ).
    t_tx04_upd-ppnbas   = t_tx03-fakppn.
    t_tx04_upd-ppnbmbas = t_tx03-fakppnbm.
  ENDIF.

*  t_tx04_upd-ppnotstd = t_tx03-fakppn.
  t_tx04_upd-ppnbm    = t_tx03-fakppnbm.
  COLLECT t_tx04_upd.

ENDFORM.                    " F_COLLECT_FROM03_GSBER

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_FROM02_CAB_GSBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_from02_cab_gsber.
  CASE t_tx02-ptype.
    WHEN c_type_n.
      IF t_tx02-fakturno EQ space.
*        t_tx04_upd-ppnotsda_cab = t_tx02-ppnlast.
        t_tx04_upd-ppnbmsda_cab = t_tx02-ppnbmlast.
      ENDIF.
    WHEN c_type_r OR
****added for MKM by Rahmadi 08/03/2004
         c_type_p.
      IF NOT t_tx02-noretur IS INITIAL.
        t_tx04_upd-ppnretur_cab = t_tx02-ppnlast.  "original code
      ELSE.
        CLEAR t_tx04_upd-ppnretur_cab.
      ENDIF.
****end of addition
  ENDCASE.
  COLLECT t_tx04_upd.


ENDFORM.                    " F_COLLECT_FROM02_CAB_GSBER

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_FROM02_GSBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_collect_from02_gsber.

  CASE t_tx02-ptype.
    WHEN c_type_n.
      IF t_tx02-fakturno EQ space.
*        t_tx04_upd-ppnotsda = t_tx02-ppnlast.
        t_tx04_upd-ppnbmsda = t_tx02-ppnbmlast.
      ENDIF.
    WHEN c_type_r OR
****added for MKM by Rahmadi 08/03/2004
         c_type_p.
      IF NOT t_tx02-noretur IS INITIAL.
        t_tx04_upd-ppnretur = t_tx02-ppnlast.  "original code
      ELSE.
        CLEAR t_tx04_upd-ppnretur.
      ENDIF.
****end of addition
  ENDCASE.
  COLLECT t_tx04_upd.

ENDFORM.                    " F_COLLECT_FROM02_GSBER

*&---------------------------------------------------------------------*
*&      Form  F_PUSAT_7022_TX04_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pusat_7022_tx04_value.
  PERFORM f_nas_pusat_7022_tx04_value.

ENDFORM.                    " F_PUSAT_7022_TX04_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_PUSAT_7022_TX04_PPNOTSTD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pusat_7022_tx04_ppnotstd.
  PERFORM f_naspusat_7022_tx04_ppnotstd.

ENDFORM.                    " F_PUSAT_7022_TX04_PPNOTSTD

*&---------------------------------------------------------------------*
*&      Form  F_PUSAT_7022_TX04_PPNOTSDA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pusat_7022_tx04_ppnotsda.
  PERFORM f_naspusat_7022_tx04_ppnotsda.

ENDFORM.                    " F_PUSAT_7022_TX04_PPNOTSDA

*&---------------------------------------------------------------------*
*&      Form  F_PUSAT_7022TX04_PPNOTSDACAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pusat_7022tx04_ppnotsdacab.
  PERFORM f_naspst7022tx04_ppnotsdacab.

ENDFORM.                    " F_PUSAT_7022TX04_PPNOTSDACAB

*&---------------------------------------------------------------------*
*&      Form  F_PUSAT_7022TX04_PPNOTSTDCAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pusat_7022tx04_ppnotstdcab.
  PERFORM f_naspst7022tx04_ppnotstdcab.

ENDFORM.                    " F_PUSAT_7022TX04_PPNOTSTDCAB

*&---------------------------------------------------------------------*
*&      Form  F_PUSAT_7022TX04_OTHERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pusat_7022tx04_others.
  PERFORM f_naspst7022tx04_others.

ENDFORM.                    " F_PUSAT_7022TX04_OTHERS

*&---------------------------------------------------------------------*
*&      Form  F_PUSAT_7024_TX05_PUSAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pusat_7024_tx05_pusat.
*  SELECT vkorg gsber
*         masafrom fptwo
*  FROM zGDTXdt0005
*  INTO TABLE t_pusat_tx05
*  WHERE vkorg EQ   p_vkorg
*    AND gsber LIKE c_gsber_pusat.
*
*  SORT t_pusat_tx05 BY vkorg gsber masafrom DESCENDING.
*  DELETE ADJACENT DUPLICATES FROM t_pusat_tx05 COMPARING vkorg gsber.

***modified by Rahmadi
*  SELECT vkorg gsber
*         bukrs brnch
*         masafrom fptwo
*  FROM zGDTXdt0005
*  INTO CORRESPONDING FIELDS OF TABLE t_pusat_tx05
*  WHERE
****modified by Rahmadi
**        vkorg EQ   p_vkorg
**    AND gsber LIKE c_gsber_pusat.
*        bukrs EQ   p_bukrs
*    AND brnch EQ   d_ho_brnch.

  PERFORM f_pusat_7022_tx05.
***end of modification

ENDFORM.                    " F_PUSAT_7024_TX05_PUSAT

*&---------------------------------------------------------------------*
*&      Form  F_PST_NDKI_GSBERS_PPNOTSDA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pst_ndki_gsbers_ppnotsda.
  PERFORM f_nas_ndki_gsbers_ppnotsda.

ENDFORM.                    " F_PST_NDKI_GSBERS_PPNOTSDA

*&---------------------------------------------------------------------*
*&      Form  F_PST_NDKI_GSBERS_PPNOTSDA_CAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pst_ndki_gsbers_ppnotsda_cab.
  PERFORM f_nas_ndki_gsbers_ppnotsda_cab.

ENDFORM.                    " F_PST_NDKI_GSBERS_PPNOTSDA_CAB

*&---------------------------------------------------------------------*
*&      Form  F_PST_NDKI_GSBERS_PPNOTSTD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pst_ndki_gsbers_ppnotstd.
  PERFORM f_nas_ndki_gsbers_ppnotstd.

ENDFORM.                    " F_PST_NDKI_GSBERS_PPNOTSTD

*&---------------------------------------------------------------------*
*&      Form  F_PST_NDKI_GSBERS_PPNOTSTD_CAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pst_ndki_gsbers_ppnotstd_cab.
  PERFORM f_nas_ndki_gsbers_ppnotstd_cab.

ENDFORM.                    " F_PST_NDKI_GSBERS_PPNOTSTD_CAB

*&---------------------------------------------------------------------*
*&      Form  F_CAB_7012_NONDKI_PPNOTSDA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cab_7012_nondki_ppnotsda.
  PERFORM f_nas_ndki_gsbers_ppnotsda.

ENDFORM.                    " F_CAB_7012_NONDKI_PPNOTSDA

*&---------------------------------------------------------------------*
*&      Form  F_CAB_7012_NONDKI_PPNOTSDA_CAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cab_7012_nondki_ppnotsda_cab.
  PERFORM f_nas_ndki_gsbers_ppnotsda_cab.

ENDFORM.                    " F_CAB_7012_NONDKI_PPNOTSDA_CAB

*&---------------------------------------------------------------------*
*&      Form  F_CAB_7012_NONDKI_PPNOTSTD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cab_7012_nondki_ppnotstd.
  PERFORM f_nas_ndki_gsbers_ppnotstd.

ENDFORM.                    " F_CAB_7012_NONDKI_PPNOTSTD

*&---------------------------------------------------------------------*
*&      Form  F_CAB_7012_NONDKI_PPNOTSTD_CAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cab_7012_nondki_ppnotstd_cab.
  PERFORM f_nas_ndki_gsbers_ppnotstd_cab.

ENDFORM.                    " F_CAB_7012_NONDKI_PPNOTSTD_CAB

*&---------------------------------------------------------------------*
*&      Form  F_CNCC_TAXAMOUNT_ADD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cncc_taxamount_add.

  PERFORM f_cncc_tx05_nasio.

  PERFORM f_cncc_taxamount_add_value.

  PERFORM f_cncc_taxamount_add_collect.

ENDFORM.                    " F_CNCC_TAXAMOUNT_ADD

*&---------------------------------------------------------------------*
*&      Form  F_CNCC_TX05_NASIO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cncc_tx05_nasio.
  SELECT vkorg    gsber
         bukrs    brnch
         masafrom fptwo
  FROM zgdtxdt0005
  INTO CORRESPONDING FIELDS OF TABLE t_nasio_tx05
  WHERE
****modified by rahmadi
*        vkorg EQ c_vkorg_nasio
*    AND gsber EQ c_gsber_nasio.
        bukrs EQ p_bukrs
    AND gsber EQ d_hold_brnch.
****end of modification

ENDFORM.                    " F_CNCC_TX05_NASIO

*&---------------------------------------------------------------------*
*&      Form  F_CNCC_TAXAMOUNT_ADD_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cncc_taxamount_add_value.
*--PPN-OTSTD (PPN keluaran standard)
*--PPN-WAPU  (PPN keluaran standard WAPU)
  SELECT
              vkorg
              bukrs
              gsber
              brnch
              spart
              busln
              fakturno
              masatx
              batal
              returcount
              fakppn
              fakppnbm
              wapu
              form
              flaga2
              waerk
    FROM zgdtxdt0003
    INTO CORRESPONDING FIELDS OF TABLE t_tx03
    WHERE
***modified by Rahmadi
*          vkorg  EQ c_vkorg_nasio
*      AND gsber  EQ c_gsber_nasio
          brnch  EQ d_hold
***end of modification
*      AND spart  NE space
      AND fakturno NE space
      AND masatx EQ p_masa
      AND batal  NE c_batal_x
      AND returcount LT 1.

*--PPN-OTSTD (PPN keluaran standard)
*--PPN-OTSDA (PPN keluaran sederhan)

***modified by Rahmadi
*  SELECT
*              x~vkorg
*              x~gsber
*              x~spart
*              x~vbeln
*              x~posnr
*              x~gjahr
*              x~fakturno
*              x~fkart
*              x~masatx
*              x~ppnlast
*              x~ppnbmlast
*              x~pstyv
*              x~wapu
*              y~ptype
*    FROM zGDTXdt0002 AS x INNER JOIN zGDTXdt0009 AS y
*                       ON x~fkart = y~fkart
*    INTO CORRESPONDING FIELDS OF TABLE t_tx02
*    WHERE x~vkorg    EQ c_vkorg_nasio
*      AND x~gsber    EQ c_gsber_nasio
*      AND x~masatx   EQ p_masa
*      AND y~ptype    IN (c_type_n,c_type_r,c_type_p).

  DATA lt_tx04 LIKE t_tx04 OCCURS 0 WITH HEADER LINE.
  PERFORM f_t_tx02 TABLES t_tx02
                          lt_tx04
                   USING  ''.
***end of modification

ENDFORM.                    " F_CNCC_TAXAMOUNT_ADD_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_CNCC_TAXAMOUNT_ADD_COLLECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cncc_taxamount_add_collect.

*-Pusat PPNOTSTD & PPNWAPU
  PERFORM f_cncctaxamountadd_ppnotstd.

*-Pusat PPNOTSDA
  PERFORM f_cncctaxamountadd_ppnotsda.


  APPEND LINES OF t_nasio_tx05 TO t_pusat_tx05.

***added by Rahmadi
  IF d_branch_num > 1.
***end of additon
*-Nas PPNOTSDA_CAB
    PERFORM f_cncctaxamountadd_ppnotsdacab.
*-Nas PPNOTSTD_CAB
    PERFORM f_cncctaxamountadd_ppnotstdcab.
***added by Rahmadi
  ENDIF.
***end of additon

ENDFORM.                    " F_CNCC_TAXAMOUNT_ADD_COLLECT

*&---------------------------------------------------------------------*
*&      Form  F_CNCCTAXAMOUNTADD_PPNOTSTD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cncctaxamountadd_ppnotstd.
  DATA :
  ld_index LIKE sy-tabix.

  LOOP AT t_tx04_upd.
    ld_index = sy-tabix.
    LOOP AT t_tx03 WHERE
***modified by Rahmadi
*                         vkorg  = t_tx04_upd-vkorg
*                     AND gsber  = t_tx04_upd-gsber
                         bukrs  = t_tx04_upd-bukrs
                     AND brnch  = t_tx04_upd-brnch
***end of modification
                     AND masatx = t_tx04_upd-masatx.
      READ TABLE t_nasio_tx05 WITH KEY
***modified by Rahmadi
*                                       vkorg = t_tx04_upd-vkorg
*                                       gsber = t_tx04_upd-gsber
                                       bukrs = t_tx04_upd-bukrs
                                       brnch = t_tx04_upd-brnch
***end of modification
                                       fptwo(3) = t_tx03-fakturno+6(3)
                                       TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.
        ADD t_tx03-fakppn TO t_tx04_upd-ppnotstd.
        IF t_tx03-wapu EQ c_wapu_w.
          ADD t_tx03-fakppn TO t_tx04_upd-ppnwapu.
        ENDIF.
      ENDIF.
    ENDLOOP.

    MODIFY t_tx04_upd INDEX ld_index TRANSPORTING ppnotstd ppnwapu.
  ENDLOOP.

ENDFORM.                    " F_CNCCTAXAMOUNTADD_PPNOTSTD

*&---------------------------------------------------------------------*
*&      Form  F_CNCCTAXAMOUNTADD_PPNOTSDA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cncctaxamountadd_ppnotsda.
  DATA lt_tx04_upd LIKE t_tx04_upd.

*-ld_p
  LOOP AT t_tx04_upd.
    lt_tx04_upd = t_tx04_upd.

    LOOP AT t_tx02 WHERE
****modified by Rahmadi
*                         vkorg  = t_tx04_upd-vkorg
*                     AND gsber  = t_tx04_upd-gsber
                         bukrs  = t_tx04_upd-bukrs
                     AND brnch  = t_tx04_upd-brnch
                     AND fakturno EQ space
****end of modification
                     AND masatx = t_tx04_upd-masatx
                     AND ptype  = c_type_n.
      READ TABLE t_nasio_tx05 WITH KEY
****modified by Rahmadi
*                                      vkorg   = t_tx02-vkorg
*                                      gsber   = t_tx02-gsber
                                      bukrs   = t_tx02-bukrs
                                      brnch   = t_tx02-brnch
****end of modification
                                      fptwo(3) = t_tx02-fakturno+6(3)
                                      TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.
        PERFORM f_clear_tx04_upd USING lt_tx04_upd.
        t_tx04_upd-ppnotsda = t_tx02-ppnlast.
        COLLECT t_tx04_upd.
      ENDIF.
    ENDLOOP.

  ENDLOOP.

ENDFORM.                    " F_CNCCTAXAMOUNTADD_PPNOTSDA

*&---------------------------------------------------------------------*
*&      Form  F_CAB_7012_CREATE_TX04
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cab_7012_create_tx04.

  IF tn_tx04-masatx IS INITIAL.
    MESSAGE i000 WITH text-e01.
    EXIT.
  ENDIF.

  d_masatx = ts_tx04-masatx.
  ts_tx04-masatx = p_masan.

  PERFORM f_cab_7011_update_tx04.

ENDFORM.                    " F_CAB_7012_CREATE_TX04

*&---------------------------------------------------------------------*
*&      Form  F_PUSAT_7022_OPENBRANCH_TX04
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pusat_7022_openbranch_tx04.

  CLEAR : t_tx04_upd,t_tx04_upd[].

  t_tx04b-vkorg  = t_tx04_upd-vkorg  = t_tx04s-vkorg.
  t_tx04b-gsber  = t_tx04_upd-gsber  = t_tx04s-gsber.
  t_tx04b-masatx = t_tx04_upd-masatx = t_tx04s-masatx.
  t_tx04b-dki    = t_tx04_upd-dki    = t_tx04s-dki.
  t_tx04b-userid = t_tx04_upd-userid = sy-uname.
  t_tx04b-vkorgt = t_tx04s-vkorgt.
  t_tx04b-gsbert = t_tx04s-gsbert.
***added by Rahmadi
  t_tx04b-bukrs  = t_tx04_upd-bukrs  = t_tx04s-bukrs.
  t_tx04b-brnch  = t_tx04_upd-brnch  = t_tx04s-brnch.
  t_tx04b-butxt  = t_tx04s-butxt.
  t_tx04b-bdesc  = t_tx04s-bdesc.
***end of addition

  APPEND t_tx04b.
  APPEND t_tx04_upd.
***modified by Rahmadi
*  SORT t_tx04b BY vkorg gsber.
  SORT t_tx04b BY bukrs brnch.
***end of modification
  DELETE t_tx04s INDEX sy-stepl.

  break ibm_rahmadi.

***added by Rahmadi
  DATA ld_lock_subrc LIKE sy-subrc.
  CLEAR ld_lock_subrc.
  PERFORM f_release_tax_period CHANGING ld_lock_subrc.
  CHECK ld_lock_subrc = 0.
***end of addition

*-open 1 branch tax period
  MODIFY zgdtxdt0004  FROM TABLE t_tx04_upd.
  CHECK ( sy-subrc EQ 0 AND sy-dbcnt NE 0 ).
  MESSAGE i000(zab) WITH text-i82 text-i83.

ENDFORM.                    " F_PUSAT_7022_OPENBRANCH_TX04

*&---------------------------------------------------------------------*
*&      Form  F_CNCCTAXAMOUNTADD_PPNOTSDACAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cncctaxamountadd_ppnotsdacab.
  PERFORM f_naspst7022tx04_ppnotsdacab.

ENDFORM.                    " F_CNCCTAXAMOUNTADD_PPNOTSDACAB



*&---------------------------------------------------------------------*
*&      Form  F_CNCCTAXAMOUNTADD_PPNOTSTDCAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cncctaxamountadd_ppnotstdcab.
  PERFORM f_naspst7022tx04_ppnotstdcab.

ENDFORM.                    " F_CNCCTAXAMOUNTADD_PPNOTSTDCAB

*&---------------------------------------------------------------------*
*&      Form  f_t_tx02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_TX02  text
*----------------------------------------------------------------------*
FORM f_t_tx02 TABLES   ft_tx02 STRUCTURE t_tx02
                       ft_tx04 STRUCTURE t_tx04
              USING    fu_allent.

  IF fu_allent IS INITIAL.
    SELECT
                vkorg
                bukrs
                gsber
                brnch
                spart
                busln
                vbeln
                posnr
                gjahr
                fakturno
                fkart
                masatx
                ppnlast
                ppnbmlast
                pstyv
                wapu
                noretur     "added by Rahmadi for MKM 08/03/2004
                waers
      FROM zgdtxdt0002
      INTO CORRESPONDING FIELDS OF TABLE ft_tx02
      WHERE bukrs    EQ p_bukrs
        AND brnch    EQ p_brnch
        AND masatx   EQ p_masa
        AND fkart    IN r_fkart.
  ELSE.
    SELECT
                vkorg
                bukrs
                gsber
                brnch
                spart
                busln
                vbeln
                posnr
                gjahr
                fakturno
                fkart
                masatx
                ppnlast
                ppnbmlast
                pstyv
                wapu
                noretur     "added by Rahmadi for MKM 08/03/2004
                waers
      FROM zgdtxdt0002
      INTO CORRESPONDING FIELDS OF TABLE ft_tx02
      FOR ALL ENTRIES IN ft_tx04
      WHERE bukrs    EQ ft_tx04-bukrs
        AND brnch    EQ ft_tx04-brnch
        AND masatx   EQ p_masa
        AND fkart    IN r_fkart.
  ENDIF.

  CHECK sy-subrc = 0.
  LOOP AT ft_tx02.
    CLEAR t_fkart09.
    READ TABLE t_fkart09 WITH KEY fkart = ft_tx02-fkart BINARY SEARCH.
    ft_tx02-ptype = t_fkart09-ptype.
    MODIFY ft_tx02 TRANSPORTING ptype.
  ENDLOOP.

ENDFORM.                                                    " f_t_tx02

*&---------------------------------------------------------------------*
*&      Form  f_get_org
*&---------------------------------------------------------------------*
FORM f_get_org.

*-Get Company code text
  SELECT SINGLE butxt INTO d_butxt
                      FROM t001
                      WHERE bukrs = p_bukrs.

*-Get Head office branch
  CLEAR d_ho_brnch.
  READ TABLE t_txdt00101 WITH KEY bukrs = p_bukrs
                                  ho_ind = 'X'.
  IF sy-subrc <> 0.
    MESSAGE i000(zab) WITH 'Company code' p_bukrs
                           'has no head office assigned'.
    EXIT.
  ENDIF.
  d_ho_brnch = t_txdt00101-brnch.

*-Get Holding company branch
  CLEAR d_hold_brnch.
  IF d_hold IS INITIAL.
    MESSAGE i000(zab) WITH 'Company code' p_bukrs
                           'has no Holding office assigned'.
    EXIT.
  ENDIF.
  d_hold_brnch = d_hold.

ENDFORM.                    " f_get_org

*&---------------------------------------------------------------------*
*&      Form  f_closing_report
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_closing_report.

  CALL SCREEN 9000.

ENDFORM.                    " f_closing_report

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.

  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.
  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN 'CLOSE'.
      PERFORM f_update_table.
      SET SCREEN 0.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  f_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_TX04_UPD  text
*----------------------------------------------------------------------*
FORM f_alv TABLES   ft_report.

  PERFORM f_gui_message USING 'Data Collection in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat      TABLES  ft_report.
  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].

  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
  PERFORM f_alv_variant_exist USING   d_vari
                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
*   I_INTERFACE_CHECK              = ' '
*   I_BYPASSING_BUFFER             =
*   I_BUFFER_ACTIVE                = ' '
    i_callback_program             = d_repid
    i_callback_pf_status_set       = 'F_STAT_9000'
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
ENDFORM.

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

*&---------------------------------------------------------------------*
*&      Form  f_build_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FT_REPORT  text
*----------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.

  REFRESH: t_alv_fieldcat.

* Begin remark unicode coversion - DEVK966104
* 20.03.2020 - sol chirka
**  PERFORM f_fieldcatg USING ft_report:
**    'BUKRS' 'ZGDTXDT0004' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '',
**    'BRNCH' 'ZGDTXDT0004' 'BRNCH' '' '' '' '' '' '' '' '' '' '' '' '',
**    'MASATX' 'ZGDTXDT0004' 'MASATX' '' '' '' '' '' '' '' '' '' '' '' '',
**    'PPNIN' 'ZGDTXDT0004' 'PPNIN' '' '' 'VAT In' '' '' '' '' ''
**    'WAERS' '' '' '',
**    'PPNOTSTD' 'ZGDTXDT0004' 'PPNOTSTD' '' '' 'VAT Out Std' '' '' '' ''
**    '' 'WAERS' '' '' '',
**    'PPNOTSDA' 'ZGDTXDT0004' 'PPNOTSDA' '' '' 'VAT Sederhana' '' '' ''
**    '' '' 'WAERS' '' '' '',
**    'WAERS' 'ZGDTXDT0004' 'WAERS' '' '' 'Currency' '' '' ''
**    '' '' '' '' '' ''.
* End remark unicode coversion - DEVK966104
* Begin insert unicode conversion - DEVK966104
* 20.03.2020 - sol chirka
  PERFORM f_fieldcatg USING :
    'FT_REPORT' 'BUKRS'    'ZGDTXDT0004' 'BUKRS'    '' '' ''              '' '' '' '' '' ''      '' '' '',
    'FT_REPORT' 'BRNCH'    'ZGDTXDT0004' 'BRNCH'    '' '' ''              '' '' '' '' '' ''      '' '' '',
    'FT_REPORT' 'MASATX'   'ZGDTXDT0004' 'MASATX'   '' '' ''              '' '' '' '' '' ''      '' '' '',
    'FT_REPORT' 'PPNIN'    'ZGDTXDT0004' 'PPNIN'    '' '' 'VAT In'        '' '' '' '' '' 'WAERS' '' '' '',
    'FT_REPORT' 'PPNOTSTD' 'ZGDTXDT0004' 'PPNOTSTD' '' '' 'VAT Out Std'   '' '' '' '' '' 'WAERS' '' '' '',
    'FT_REPORT' 'PPNOTSDA' 'ZGDTXDT0004' 'PPNOTSDA' '' '' 'VAT Sederhana' '' '' '' '' '' 'WAERS' '' '' '',
    'FT_REPORT' 'WAERS'    'ZGDTXDT0004' 'WAERS'    '' '' 'Currency'      '' '' '' '' '' ''      '' '' ''.
* End insert unicode conversion - DEVK966104

ENDFORM.                    " F_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  f_fieldcatg
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
                          value(fu_checkbox)
                          value(fu_input).

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
  ld_fieldcat-input         = fu_input.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.

ENDFORM.                    " F_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  f_build_event
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_ALV_EVENT[]  text
*----------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.

  REFRESH: ft_events.
  CLEAR ft_events.
*  ft_events-name = slis_ev_top_of_page.
*  ft_events-form = 'F_TOP_OF_PAGE'.
*  APPEND ft_events.
*
*  CLEAR ft_events.
*  ft_events-name = slis_ev_end_of_list.
*  ft_events-form = 'F_END_OF_LIST'.
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

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  f_build_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_D_LAYOUT  text
*----------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
* fu_layout-f2code             = '&ETA'.
* fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  f_build_sortfield
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_ALV_ISORT[]  text
*----------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'BUKRS'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
*  CLEAR ld_sort.
*  ld_sort-fieldname = 'VERSB'.
*  ld_sort-up        = 'X'.
*  APPEND ld_sort TO fu_sort.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  f_build_event_exit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&OUP'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&ODN'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

ENDFORM.                    " f_build_event_exit

*&---------------------------------------------------------------------*
*&      Form  f_build_print
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_D_PRINT  text
*----------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos = 'X'.
  fu_print-no_print_selinfos  = 'X'.
  fu_print-no_coverpage       = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  f_alv_variant_exist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_VARI  text
*      -->P_D_ALV_VARIANT  text
*----------------------------------------------------------------------*
FORM f_alv_variant_exist USING     fu_vari
                         CHANGING  fc_alv_variant STRUCTURE disvariant.

  IF NOT fu_vari IS INITIAL.
    MOVE fu_vari TO fc_alv_variant-variant.
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

*---------------------------------------------------------------------*
*       FORM f_set_pf_status                                          *
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.

  sy-lsind = 0.
  SET PF-STATUS 'STANDARD_9000'.

ENDFORM.                    " F_SET_PF_STATUS

*&---------------------------------------------------------------------*
*&      Form  f_lock_branch
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_lock_branch.

  DATA ld_user LIKE sy-msgv1.

  CALL FUNCTION 'ENQUEUE_EZGDTXDT0004'
   EXPORTING
     mode_zgdtxdt0004       = 'E'
     mandt                  = sy-mandt
     bukrs                  = p_bukrs
     brnch                  = p_brnch
     masatx                 = p_masa
*   X_BUKRS                = ' '
*   X_BRNCH                = ' '
*   X_MASATX               = ' '
*   _SCOPE                 = '2'
*   _WAIT                  = ' '
*   _COLLECT               = ' '
   EXCEPTIONS
     foreign_lock           = 1
     system_failure         = 2
     OTHERS                 = 3
            .
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
        ld_user = sy-msgv1.
        MESSAGE e000(zab) WITH 'Tax period is locked by'
                               ld_user.
      WHEN 2 OR 3.
        MESSAGE a000(zab) WITH 'System Failure'.
    ENDCASE.
  ENDIF.

ENDFORM.                    " f_lock_branch

*&---------------------------------------------------------------------*
*&      Form  f_lock_company
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_lock_company.

  DATA ld_user LIKE sy-msgv1.

  CALL FUNCTION 'ENQUEUE_EZGDTXDT0004'
   EXPORTING
     mode_zgdtxdt0004       = 'E'
     mandt                  = sy-mandt
     bukrs                  = p_bukrs
*     brnch                  = p_brnch
     masatx                 = p_masa
*   X_BUKRS                = ' '
*   X_BRNCH                = ' '
*   X_MASATX               = ' '
*   _SCOPE                 = '2'
*   _WAIT                  = ' '
*   _COLLECT               = ' '
   EXCEPTIONS
     foreign_lock           = 1
     system_failure         = 2
     OTHERS                 = 3
            .
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
        ld_user = sy-msgv1.
        MESSAGE e000(zab) WITH 'Tax period is locked by'
                               ld_user.
      WHEN 2 OR 3.
        MESSAGE a000(zab) WITH 'System Failure'.
    ENDCASE.
  ENDIF.

ENDFORM.                    " f_lock_company

*&---------------------------------------------------------------------*
*&      Form  f_lock_nasional
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_lock_nasional.

  DATA ld_user LIKE sy-msgv1.

  CALL FUNCTION 'ENQUEUE_EZGDTXDT0004'
   EXPORTING
     mode_zgdtxdt0004       = 'E'
     mandt                  = sy-mandt
*     bukrs                  = p_bukrs
*     brnch                  = p_brnch
     masatx                 = p_masa
*   X_BUKRS                = ' '
*   X_BRNCH                = ' '
*   X_MASATX               = ' '
*   _SCOPE                 = '2'
*   _WAIT                  = ' '
*   _COLLECT               = ' '
   EXCEPTIONS
     foreign_lock           = 1
     system_failure         = 2
     OTHERS                 = 3
            .
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
        ld_user = sy-msgv1.
        MESSAGE e000(zab) WITH 'Tax period is locked by'
                               ld_user.
      WHEN 2 OR 3.
        MESSAGE a000(zab) WITH 'System Failure'.
    ENDCASE.
  ENDIF.

ENDFORM.                    " f_lock_nasional

*&---------------------------------------------------------------------*
*&      Form  f_lock_tax_period
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_lock_tax_period CHANGING fc_subrc LIKE sy-subrc.

  DATA ld_repid LIKE sy-repid.
  DATA ld_uname LIKE sy-uname.
  DATA: tx04usr LIKE indx-srtfd VALUE 'ZGDTXDT0106'.

  fc_subrc = 0.
  ld_repid = sy-repid.
  CLEAR ld_uname.
  CALL FUNCTION 'Z_GDTXFC_LOCK_PROGRAM'
       EXPORTING
            fi_repid         = ld_repid
       IMPORTING
            fe_uname         = ld_uname
       EXCEPTIONS
            no_program_found = 1
            program_running  = 2
            OTHERS           = 3.
  fc_subrc = sy-subrc.
  IF fc_subrc <> 0.
    CASE fc_subrc.
      WHEN 1.
        MESSAGE i000(zab) WITH 'Please maintain Tax period program to'
                               'ZGDTXDT0106 table'.
      WHEN 2.
        IMPORT zgdtxdt0106-uname FROM MEMORY ID tx04usr.
        ld_uname = zgdtxdt0106-uname.
        MESSAGE i000(zab) WITH 'Tax period program is still locked by'
                               ld_uname.
    ENDCASE.
    EXIT.
  ENDIF.

ENDFORM.                    " f_lock_tax_period

*&---------------------------------------------------------------------*
*&      Form  f_release_tax_period
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--FC_SUBRC  text
*----------------------------------------------------------------------*
FORM f_release_tax_period CHANGING fc_subrc LIKE sy-subrc.

  DATA ld_repid LIKE sy-repid.

  ld_repid = sy-repid.
  fc_subrc = 0.
  CALL FUNCTION 'Z_GDTXFC_RELEASE_PROGRAM'
       EXPORTING
            fi_repid         = ld_repid
       IMPORTING
            fe_subrc         = fc_subrc
       EXCEPTIONS
            no_program_found = 1
            OTHERS           = 2.
  IF sy-subrc <> 0.
    fc_subrc = sy-subrc.
    MESSAGE a000(zab) WITH 'Tax period program is not maintained in'
                           'ZGDTXDT0106 table'.
  ENDIF.

ENDFORM.                    " f_release_tax_period
