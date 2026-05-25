*----------------------------------------------------------------------*
***INCLUDE ZF_JURNAL_EXPV1M01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  DATA : lv_subrc    TYPE sy-subrc,
         ls_type     LIKE LINE OF gt_typeexp.
  DATA : text_del    TYPE gui_dyntxt,
         ls_xshp     LIKE LINE OF gt_xshp,
         ls_yshp     LIKE LINE OF gt_yshp.

  CLEAR : fcode[], fcode, ok_code, fill.

  CASE sy-dynnr.
    WHEN '0801'.
      CONCATENATE icon_delete 'Delete No.Pol.' INTO text_del
      SEPARATED BY space.

      PERFORM f_excluding_ucomm USING : 'CONT', '&REVDO', 'MORE',
                                        'PREV', '&SIM', '&ADD',
                                        '&SHP', '&ADDL', '&DELL',
                                        '&REFR', 'CLIP'.

      SET PF-STATUS 'STATUS' EXCLUDING fcode.
      SET TITLEBAR 'TITLE_KENDARAAN'.

      DESCRIBE TABLE gt_mstk LINES fill.
      tc_nopol-lines = fill.

      SET CURSOR FIELD 'ZFMSTKEN-ZNOPOL' LINE 1.

    WHEN '0802'.
      PERFORM f_excluding_ucomm USING : '&DEL', 'CONT', '&REVDO',
                                        'MORE', 'PREV', '&SIM',
                                        '&ADD', '&SHP', '&ADDL',
                                        '&DELL', '&REFR', 'CLIP'.

      SET PF-STATUS 'STATUS' EXCLUDING fcode.
      SET TITLEBAR 'TITLE_PERSONEL'.

      DESCRIBE TABLE gt_mstp LINES fill.

    WHEN '0803'.
      CONCATENATE icon_delete 'Delete Expense' INTO text_del
      SEPARATED BY space.

      PERFORM f_excluding_ucomm USING : 'SAVE', '&DEL', 'CONT',
                                        '&REVDO', 'PREV', '&SIM',
                                        '&ADD', '&SHP', '&ADDL',
                                        '&DELL', '&REFR', 'CLIP'.

      SET PF-STATUS 'STATUS' EXCLUDING fcode.

      DESCRIBE TABLE gt_ship LINES fill.
      tc_shipment-lines = fill.

    WHEN '0804'.
      PERFORM f_excluding_ucomm USING : '&DEL', 'CONT', '&REVDO',
                                        'PREV', '&SIM', '&ADD',
                                        '&SHP', '&ADDL', '&DELL',
                                        '&REFR', 'CLIP'.

      SET PF-STATUS 'STATUS' EXCLUDING fcode.

      DESCRIBE TABLE gt_expe LINES fill.
      tc_expense-lines = fill.

    WHEN '0805'.
      CASE sy-tcode.
        WHEN 'ZF63B'.
          PERFORM f_excluding_ucomm USING : '&DEL', 'CONT', '&REVDO',
                                            'MORE', 'PREV', '&SIM',
                                            '&ADD', '&SHP', '&ADDL',
                                            '&DELL', '&REFR', 'CLIP'.
        WHEN 'ZF63N'.
          PERFORM f_excluding_ucomm USING : '&DEL', 'CONT', '&REVDO',
                                            'MORE', '&SIM', '&ADD',
                                            '&SHP', '&ADDL', '&DELL',
                                            '&REFR', 'CLIP'.
      ENDCASE.

      SET PF-STATUS 'STATUS' EXCLUDING fcode.

      SORT gt_save BY type buzei.
      DESCRIBE TABLE gt_save LINES fill.
      tc_final-lines = fill.

    WHEN '0806'.
      PERFORM f_excluding_ucomm USING : '&DEL', '&REVDO', 'MORE',
                                        'PREV', '&SIM', '&ADD',
                                        '&SHP', '&ADDL', '&DELL',
                                        '&REFR', 'CLIP'.

      SET PF-STATUS 'STATUS' EXCLUDING fcode.
      SET TITLEBAR 'TITLE_CASHBANK'.

      DESCRIBE TABLE gt_bsik LINES fill.
      tc_advance-lines = fill.

    WHEN '0807'.
      PERFORM f_excluding_ucomm USING : '&DEL', 'MORE', 'PREV',
                                        '&SIM', '&ADD', '&SHP',
                                        '&ADDL', '&DELL', '&REFR',
                                        'CLIP'.

      SET PF-STATUS 'STATUS' EXCLUDING fcode.
      SET TITLEBAR 'TITLE_REVERSE'.

    WHEN '0808'.
      PERFORM f_excluding_ucomm USING : 'PREV', '&SIM', '&ADD',
                                        '&SHP', '&ADDL', '&DELL',
                                        '&REFR', 'CLIP'.

      SET PF-STATUS 'TOEXECUTE' EXCLUDING fcode.
      SET TITLEBAR 'TITLE_VOUCHER'.

    WHEN '0809'.
      PERFORM f_excluding_ucomm USING : '&DEL', '&REVDO', 'MORE',
                                        'PREV', '&SIM', '&ADD',
                                        '&SHP', '&ADDL', '&DELL',
                                        '&REFR', 'CLIP'.

      SET PF-STATUS 'STATUS' EXCLUDING fcode.

    WHEN '0810'.
      PERFORM f_excluding_ucomm USING : 'SAVE', '&DEL', 'CONT',
                                        '&REVDO', 'PREV', '&SIM',
                                        '&ADD', '&SHP', '&ADDL',
                                        '&DELL', '&REFR', 'CLIP'.

      SET PF-STATUS 'STATUS' EXCLUDING fcode.
      SET TITLEBAR 'TRANSACTION' WITH gs_ship-description.

      DESCRIBE TABLE gt_bsik LINES fill.
      tc_advance-lines = fill.

    WHEN '0811'.
      PERFORM f_excluding_ucomm USING : 'SAVE', '&DEL', 'CONT',
                                        '&REVDO', 'PREV', 'MORE',
                                        'CLIP'.
      IF gs_gtype-shipment IS INITIAL.
        PERFORM f_excluding_ucomm USING : '&SHP'.
      ENDIF.

      DESCRIBE TABLE gt_yexp LINES fill.
      tc_transaction-lines = fill.

      SET PF-STATUS 'STATUS' EXCLUDING fcode.
      SET TITLEBAR 'TRANSACTION' WITH gs_ship-description.

    WHEN '0812'.
      PERFORM f_excluding_ucomm USING : '&REVDO', 'MORE',
                                        'PREV', '&SIM', '&ADD',
                                        '&SHP', '&ADDL', '&DELL',
                                        '&REFR', 'CLIP'.

      IF gt_yshp[] IS INITIAL.
        DO 255 TIMES.
          APPEND INITIAL LINE TO gt_yshp.
        ENDDO.
      ENDIF.

      DESCRIBE TABLE gt_yshp LINES fill.
      tc_shipnew-lines = fill.

      SET PF-STATUS 'STATUS' EXCLUDING fcode.

    WHEN '0813'.
      PERFORM f_excluding_ucomm USING : '&DEL', 'CONT', '&REVDO',
                                        'MORE', '&SIM',
                                        '&ADD', '&SHP', '&ADDL',
                                        '&DELL', '&REFR', 'CLIP'.

      DESCRIBE TABLE gt_yexp LINES fill.
      tc_simtran-lines = fill.

      CLEAR : gt_yshp[], gt_yshp, ls_xshp.
      LOOP AT gt_xshp INTO ls_xshp.
        ls_yshp = ls_xshp.
        APPEND ls_yshp TO gt_yshp.
        CLEAR ls_yshp.
      ENDLOOP.

      DESCRIBE TABLE gt_yshp LINES fill.
      tc_simship-lines = fill.

      SET PF-STATUS 'STATUS' EXCLUDING fcode.
      SET TITLEBAR 'TRANSACTION' WITH gs_ship-description.
  ENDCASE.
ENDMODULE.                 " STATUS   OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  DATA : ls_save      LIKE LINE OF gt_save,
         ls_expe      LIKE LINE OF gt_expe,
         ls_tyexpdtl  LIKE LINE OF gt_tyexpdtl,
         ls_kmh       LIKE LINE OF gt_kmh,
         lt_mstk      TYPE STANDARD TABLE OF ty_mstk,
*         ls_mstk      LIKE LINE OF lt_mstk,
         ls_mstp      TYPE ty_mstp,
         ls_pddklk    LIKE LINE OF gt_pddklk,
         ls_typeexp   LIKE LINE OF gt_typeexp,
         ls_accexp    LIKE LINE OF gt_accexp,
         ls_tbsl      LIKE LINE OF gt_tbsl,
         ls_xexp      LIKE LINE OF gt_xexp,
         ls_yexp      LIKE LINE OF gt_yexp,
         lv_flag,
         lv_total     TYPE zfexpense-wrbtr,
         ls_depar     LIKE LINE OF gt_proseq,
         lv_len1      TYPE i,
         lv_len2      TYPE i,
         ls_proseq    LIKE LINE OF gt_proseq.

  CLEAR : ls_yshp, ls_xshp.

  CASE sy-dynnr.
    WHEN '0801'.

    WHEN '0802'.
      IF zfmstper-zidke IS NOT INITIAL.
        PERFORM f_read_master_kendaraan USING zfmstper-zidke ''.
      ENDIF.

      IF gs_mstp-salesman IS INITIAL.
        PERFORM f_modify_screen USING : 'SAL' '' '0' '' ''.
      ELSE.
        PERFORM f_modify_screen USING : 'SAL' '' '1' '' ''.
      ENDIF.

      IF gs_mstp-vendor IS INITIAL.
        PERFORM f_modify_screen USING : 'VEN' '' '0' '' ''.
      ELSE.
        PERFORM f_modify_screen USING : 'VEN' '' '1' '' ''.
      ENDIF.

      IF gs_mstp-customer IS INITIAL.
        PERFORM f_modify_screen USING : 'CUS' '' '0' '' ''.
      ELSE.
        PERFORM f_modify_screen USING : 'CUS' '' '1' '' ''.
      ENDIF.

      PERFORM f_modify_screen USING : 'KOS' '' gv_input '' ''.

      IF zfmstper-vbund IS INITIAL.
        zfmstper-vbund = 'OTHERS'.
      ENDIF.

    WHEN '0803'.
      SET TITLEBAR 'TRANSACTION' WITH gs_ship-description.

      PERFORM f_dynp_value_read USING 'ZFEXPENSE-BKTXT'
                                CHANGING gv_bktxt.

      IF gs_ship-shipment IS INITIAL.
        tc_shipment-invisible = 'X'.
      ENDIF.

      IF gs_ship-lfa1 IS NOT INITIAL.
        PERFORM f_modify_screen USING : 'NOP' '0' '' '' ''.
      ENDIF.

      IF gs_ship-znopol IS NOT INITIAL.
        PERFORM f_modify_screen USING : 'NOP' '' '' '' '1'.
      ENDIF.

      IF gs_gtype-advance IS NOT INITIAL.
        PERFORM f_modify_screen USING : 'REK' '0' '' '' ''.
      ENDIF.

      CASE sy-tcode.
        WHEN 'ZF63B'.
          PERFORM f_modify_screen USING : 'KTX' '0' '' '' '',
                                          'KDV' '0' '' '' ''.
        WHEN OTHERS.
          IF gv_xbkt IS NOT INITIAL.
            PERFORM f_modify_screen USING : 'BKT' '' '0' '' ''.
          ENDIF.
      ENDCASE.

    WHEN '0804'.
*      READ TABLE gt_typeexp INTO ls_type WITH KEY type = zfexpense-typet.
*      IF sy-subrc = 0.
      PERFORM f_hidden_column USING : 'DES' ''.
*                                        'TRH' ls_type-zharian.
*      ENDIF.

    WHEN '0805'.
      CLEAR gv_azsal.
      LOOP AT gt_save INTO ls_save.
        IF ls_save-shkzg = 'H'.
          ls_save-wrbtrv = ls_save-wrbtr * -1.
        ELSE.
          ls_save-wrbtrv = ls_save-wrbtr.
        ENDIF.
        ADD ls_save-wrbtrv TO gv_azsal.
      ENDLOOP.

      PERFORM f_hidden_column USING : 'DES' ''.

    WHEN '0806'.
      IF gs_gtype-advance = 'X'.
        PERFORM f_modify_screen USING : 'ADV' '0' '' '' ''.
      ENDIF.

    WHEN '0808'.
      IF gs_gtype-hkont IS NOT INITIAL.
*        zfexpense-hkont = gs_gtype-hkont.
*        PERFORM f_modify_screen USING : 'HKO' '' '0' '' ''.
      ENDIF.

      IF gs_gtype-advance IS INITIAL.
        PERFORM f_modify_screen USING : 'IDH' '0' '' '' '',
                                        'HKO' '0' '' '' ''.
      ENDIF.

    WHEN '0809'.
      IF radio17 IS NOT INITIAL.
        PERFORM f_modify_screen USING : 'PX1' '0' '' '' '',
                                        'TRP' '0' '' '' '',
                                        'KET' '0' '' '' ''.
      ELSE.
        PERFORM f_modify_screen USING : 'PAY' '0' '' '' ''.
        IF gs_gtype-advance IS NOT INITIAL.
          PERFORM f_modify_screen USING : 'PX1' '0' '' '' ''.
        ENDIF.
        IF gv_lines > 1.
          PERFORM f_modify_screen USING : 'KET' '' '0' '' ''.
        ENDIF.
      ENDIF.
    WHEN '0810'.
      zfexpense-waers   = t093b-waers.
      IF gs_ship-shipment IS INITIAL.
        tc_shipment-invisible = 'X'.
        PERFORM f_modify_screen USING : 'SHP' '' '' '1' ''.
      ENDIF.

    WHEN '0811'.
      IF gv_depar IS NOT INITIAL.
        SET CURSOR FIELD 'ZFTRANSACTION-DEPARTEMEN'.
      ENDIF.
      CLEAR lv_flag.
      LOOP AT gt_xexp INTO ls_xexp WHERE znopol = zfexpense-znopol.
        IF ls_xexp-icon IS NOT INITIAL.
          lv_flag = 'X'.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_flag IS INITIAL.
        PERFORM f_hidden_column USING : 'ICO' ''.
      ELSE.
        PERFORM f_hidden_column USING : 'ICO' 'X'.
      ENDIF.

      PERFORM f_hidden_column USING : 'DES' ''.

      PERFORM f_modify_screen USING : 'LTX' '' '1' '' ''.

      SELECT SINGLE *
        FROM zf63masterkend
        INTO CORRESPONDING FIELDS OF gs_mstk
        WHERE bukrs   = zfexpense-bukrs
          AND gsber   = zfexpense-gsber
          AND vkbur   = zfexpense-vkbur
          AND znopol  = zfexpense-znopol.

      IF zftransaction-ltext IS NOT INITIAL.
        PERFORM f_modify_screen USING : 'LTX' '' '0' '' ''.

        CLEAR : ls_tyexpdtl.
        READ TABLE gt_tyexpdtl INTO ls_tyexpdtl
                               WITH KEY ltext = zftransaction-ltext.
        IF sy-subrc = 0.
          IF zftransaction-waers IS INITIAL.
            zftransaction-waers  = ls_tyexpdtl-waers.
          ENDIF.
          IF ls_tyexpdtl-zamnt IS INITIAL.
            PERFORM f_modify_screen USING : 'WRB' '' '1' '' ''.
          ELSE.
            PERFORM f_modify_screen USING : 'WRB' '' '0' '' ''.
          ENDIF.

          IF ls_tyexpdtl-zpercen IS INITIAL.
            PERFORM f_modify_screen USING : 'DEP' '' '1' '' '1'.
          ELSE.
            PERFORM f_modify_screen USING : 'DEP' '' '0' '' ''.
            CLEAR zftransaction-departemen.
          ENDIF.
        ENDIF.

        IF zftransaction-meins IS INITIAL.
          zftransaction-meins = ls_tyexpdtl-meins.
        ENDIF.
        IF ls_tyexpdtl-meins IS NOT INITIAL.
          PERFORM f_modify_screen USING : 'MEN' '' '1' '' ''.
        ELSE.
          PERFORM f_modify_screen USING : 'MEN' '' '0' '' ''.
          CLEAR : zftransaction-meins, zftransaction-menge.
        ENDIF.

        IF zftransaction-speed IS INITIAL .
          zftransaction-speed = ls_tyexpdtl-speed.
        ENDIF.

        SELECT *
          FROM zf63kmhexph
          INTO CORRESPONDING FIELDS OF TABLE gt_kmh
          WHERE bukrs   = zfexpense-bukrs
            AND gsber   = zfexpense-gsber
            AND vkbur   = zfexpense-vkbur
            AND znopol  = zfexpense-znopol
            AND type    = ls_tyexpdtl-type
            AND lvorm   = space.

        SORT gt_kmh BY znopol bldat DESCENDING buzei DESCENDING.
        CLEAR ls_kmh.
        READ TABLE gt_kmh INTO ls_kmh INDEX 1.

        IF zftransaction-kmstr IS INITIAL.
          zftransaction-kmstr = ls_kmh-kmend.
        ENDIF.

        IF ls_tyexpdtl-zstrf IS NOT INITIAL.
          IF gs_mstk-anln1 IS NOT INITIAL.
            PERFORM f_modify_screen USING : 'KMS' '' '0' '' ''.
          ELSE.
            PERFORM f_modify_screen USING : 'KMS' '' '1' '' ''.
          ENDIF.
        ELSE.
          PERFORM f_modify_screen USING : 'KMS' '' '0' '' ''.
        ENDIF.

        IF ls_tyexpdtl-zendf IS NOT INITIAL.
          PERFORM f_modify_screen USING : 'KME' '' '1' '' ''.
        ELSE.
          PERFORM f_modify_screen USING : 'KME' '' '0' '' ''.
        ENDIF.

        SELECT SINGLE *
          FROM zf63masterperson
          INTO CORRESPONDING FIELDS OF ls_mstp
          WHERE bukrs   = zfexpense-bukrs
            AND gsber   = zfexpense-gsber
            AND vkbur   = zfexpense-vkbur
            AND zidno   = zfexpense-zidno.

        IF ls_tyexpdtl-zpercen IS INITIAL.
          IF zftransaction-departemen IS INITIAL.
            lv_len1 = STRLEN( ls_mstp-kostl ).
            lv_len1 = lv_len1 - 3.
            CLEAR ls_depar.
            LOOP AT gt_proseq INTO ls_depar.
              lv_len2 = STRLEN( ls_depar-kostl ).
              lv_len2 = lv_len2 - 3.
              IF lv_len2 >= 0.
                IF ls_depar-kostl+lv_len2(3) = ls_mstp-kostl+lv_len1(3).
                  IF ls_mstp-wwsfr IS INITIAL AND
                    ls_mstp-wwpos IS INITIAL.
                    zftransaction-departemen   = ls_depar-departemen.
                    EXIT.
                  ELSEIF ls_mstp-wwsfr IS NOT INITIAL.
                    IF ls_depar-wwsfr = ls_mstp-wwsfr.
                      IF ls_mstp-wwsfr IS NOT INITIAL.
                        zftransaction-departemen   = ls_depar-departemen.
                        EXIT.
                      ENDIF.
                    ENDIF.
                  ELSEIF ls_mstp-wwpos IS NOT INITIAL.
                    IF ls_depar-wwpos = ls_mstp-wwpos.
                      IF ls_mstp-wwpos IS NOT INITIAL.
                        zftransaction-departemen   = ls_depar-departemen.
                        EXIT.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.

        CLEAR ls_pddklk.
        READ TABLE gt_pddklk INTO ls_pddklk
                             WITH KEY bukrs    = zfexpense-bukrs
                                      gsber    = zfexpense-gsber
                                      vkbur    = zfexpense-vkbur
                                      type     = ls_tyexpdtl-type
                                      item     = ls_tyexpdtl-item
                                      jabatpd  = ls_mstp-jabatpd.
        IF sy-subrc = 0.
          IF ls_pddklk-trf_hari IS NOT INITIAL.
            zftransaction-trf_hari  = ls_pddklk-trf_hari.
            zftransaction-wrbtr     = zftransaction-menge * zftransaction-trf_hari.
          ELSEIF ls_pddklk-trf_inap IS NOT INITIAL.
            zftransaction-trf_inap  = ls_pddklk-trf_inap.
            zftransaction-wrbtr     = zftransaction-menge * zftransaction-trf_inap.
          ENDIF.
        ENDIF.

        CLEAR ls_typeexp.
        READ TABLE gt_typeexp INTO ls_typeexp
                              WITH KEY gtype = zfexpense-gtype
                                       type  = ls_pddklk-type.
        IF sy-subrc = 0.
          IF ls_typeexp-zdklk IS NOT INITIAL.
            PERFORM f_modify_screen USING : 'TRH' '' '1' '' ''.
          ELSE.
            PERFORM f_modify_screen USING : 'TRH' '' '0' '' ''.
          ENDIF.
        ENDIF.

        CLEAR ls_typeexp.
        READ TABLE gt_typeexp INTO ls_typeexp
                              WITH KEY gtype = zfexpense-gtype
                                       type  = ls_tyexpdtl-type.
        IF sy-subrc = 0.
          zftransaction-vbund   = gs_gtype-vbund.
          IF ls_typeexp-zvbund IS NOT INITIAL.
            PERFORM f_modify_screen USING : 'VBU' '' '1' '' ''.
          ELSE.
            PERFORM f_modify_screen USING : 'VBU' '' '0' '' ''.
          ENDIF.
          IF ls_typeexp-ztext IS NOT INITIAL.
            PERFORM f_modify_screen USING : 'TXT' '' '1' '' ''.
          ELSE.
            PERFORM f_modify_screen USING : 'TXT' '' '0' '' ''.
          ENDIF.
        ENDIF.
      ENDIF.

      CLEAR : gt_yexp[], gt_yexp, lv_total, ls_xexp.
      LOOP AT gt_xexp INTO ls_xexp WHERE znopol = zfexpense-znopol.
        ls_yexp = ls_xexp.

        PERFORM f_dc_fr_type USING ls_xexp-bukrs ls_xexp-gtype ls_xexp-type
                             CHANGING ls_xexp-wrbtr.

        IF ls_xexp-icon IS INITIAL.
          ADD ls_xexp-wrbtr TO lv_total.
        ENDIF.
        APPEND ls_yexp TO gt_yexp.
        CLEAR ls_yexp.
      ENDLOOP.

      WRITE lv_total TO zftransaction-totalt CURRENCY 'IDR'.

    WHEN '0812'.
      CLEAR : gt_yshp[], gt_yshp, ls_xshp.
      LOOP AT gt_xshp INTO ls_xshp WHERE znopol = zfexpense-znopol.
        ls_yshp = ls_xshp.
        APPEND ls_yshp TO gt_yshp.
        CLEAR ls_yshp.
      ENDLOOP.

    WHEN '0813'.
      CLEAR : gt_yexp[], gt_yexp, ls_xexp, lv_total.
      LOOP AT gt_xexp INTO ls_xexp WHERE icon = space.
        ls_yexp = ls_xexp.

        PERFORM f_dc_fr_type USING ls_xexp-bukrs ls_xexp-gtype ls_xexp-type
                             CHANGING ls_xexp-wrbtr.

        ADD ls_xexp-wrbtr TO lv_total.
        APPEND ls_yexp TO gt_yexp.
        CLEAR ls_yexp.
      ENDLOOP.

      WRITE lv_total TO zftransaction-totalt CURRENCY 'IDR'.
      WRITE gv_dmbtr TO zftransaction-advant CURRENCY 'IDR'.
      PERFORM f_hidden_column USING : 'DES' ''.
  ENDCASE.
ENDMODULE.                 " PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
MODULE fill_table_control OUTPUT.
  DATA : lv_line      TYPE i,
         ls_bsik      LIKE LINE OF gt_bsik,
         ls_typex     LIKE LINE OF gt_typeexp,
         lv_wrbtr     TYPE zfexpense-wrbtrv.

  CASE sy-dynnr.
    WHEN '0801'.
      READ TABLE gt_mstk INTO zfmstken INDEX tc_nopol-current_line.
      IF sy-subrc = 0.
        IF zfmstken-znopol IS NOT INITIAL.
          zfmstken-buzei = tc_nopol-current_line * 10.
          lv_line = tc_nopol-current_line + 1.
          PERFORM f_modify_screen USING : 'BUZ' '' '0' '' ''.
        ENDIF.
        IF zfmstken-loevm IS NOT INITIAL.
          PERFORM f_modify_screen USING : 'NOP' '' '0' '' ''.
        ENDIF.
        IF gv_subrc IS INITIAL.
          SET CURSOR FIELD 'ZFMSTKEN-ZNOPOL' LINE lv_line.
        ENDIF.
      ENDIF.
    WHEN '0802'.
    WHEN '0803'.
      READ TABLE gt_ship INTO zfexpense INDEX tc_shipment-current_line.
    WHEN '0804'.
      READ TABLE gt_expe INTO zfexpense INDEX tc_expense-current_line.
      IF sy-subrc = 0.
        READ TABLE gt_typeexp INTO ls_typex
                              WITH KEY bukrs = pa_bukrs
                                       gtype = pa_gtype
                                       type  = zfexpense-type.
        IF sy-subrc = 0.
          IF ls_typex-ztext IS NOT INITIAL.
            PERFORM f_modify_screen USING : 'TXT' '' '1' '' ''.
          ENDIF.
          IF ls_typex-zvbund IS NOT INITIAL.
            IF zfexpense-vbund IS INITIAL.
              IF gs_gtype-vbund IS INITIAL.
                zfexpense-vbund = 'OTHERS'.
              ELSE.
                zfexpense-vbund = gs_gtype-vbund.
              ENDIF.
            ENDIF.

            IF zfexpense-vbund = 'OTHERS'.
              PERFORM f_modify_screen USING : 'VBU' '' '1' '' ''.
            ELSE.
              PERFORM f_modify_screen USING : 'VBU' '' '0' '' ''.
            ENDIF.
          ENDIF.
        ENDIF.

        IF zfexpense-meins IS NOT INITIAL.
          PERFORM f_modify_screen USING : 'MEN' '' '1' '' ''.
        ENDIF.
        CLEAR ls_tyexpdtl.
        READ TABLE gt_tyexpdtl INTO ls_tyexpdtl
                               WITH KEY gtype = pa_gtype
                                        type  = zfexpense-type
                                        item  = zfexpense-buzei.
        IF sy-subrc = 0.
          IF ls_tyexpdtl-zstrf IS NOT INITIAL.
            PERFORM f_modify_screen USING : 'KMS' '' '1' '' ''.
          ENDIF.
          IF ls_tyexpdtl-zendf IS NOT INITIAL.
            PERFORM f_modify_screen USING : 'KME' '' '1' '' ''.
          ENDIF.
          IF ls_tyexpdtl-zamnt IS INITIAL.
            PERFORM f_modify_screen USING : 'WRB' '' '1' '' ''.
          ENDIF.
        ENDIF.
        IF gs_mstk-anln1 IS NOT INITIAL.
          IF zfexpense-kmstr IS NOT INITIAL.
            PERFORM f_modify_screen USING : 'KMS' '' '0' '' ''.
          ENDIF.
        ENDIF.
        IF zfexpense-trf_inap IS NOT INITIAL.
          PERFORM f_modify_screen USING : 'TRI' '' '1' '' ''.
        ENDIF.
      ENDIF.

    WHEN '0805'.
      READ TABLE gt_save INTO zfexpense INDEX tc_final-current_line.
      IF sy-subrc = 0.
        IF zfexpense-shkzg = 'H'.
          zfexpense-wrbtrv = zfexpense-wrbtr * -1.
        ELSE.
          zfexpense-wrbtrv = zfexpense-wrbtr.
        ENDIF.
        zfexpense-azsal  = gv_azsal.
      ENDIF.

    WHEN '0806'.
      IF zfexpense-advance IS INITIAL.
        PERFORM f_modify_screen USING : 'TCA' '' '' '1' ''.
      ENDIF.

      READ TABLE gt_bsik INTO ls_bsik INDEX tc_advance-current_line.
      IF sy-subrc = 0.
        zfexpense-zuonr   = ls_bsik-zuonr.
        zfexpense-belnr   = ls_bsik-belnr.
        zfexpense-gjahr   = ls_bsik-gjahr.
        zfexpense-budat   = ls_bsik-budat.
        zfexpense-bldat   = ls_bsik-bldat.
        zfexpense-dmbtr   = ls_bsik-dmbtr.
        zfexpense-sgtxt   = ls_bsik-sgtxt.
      ENDIF.

    WHEN '0810'.
      IF zfexpense-advance IS INITIAL.
        PERFORM f_modify_screen USING : 'TCA' '' '' '1' ''.
      ENDIF.

      READ TABLE gt_bsik INTO ls_bsik INDEX tc_advance-current_line.
      IF sy-subrc = 0.
        zfexpense-zuonr   = ls_bsik-zuonr.
        zfexpense-belnr   = ls_bsik-belnr.
        zfexpense-gjahr   = ls_bsik-gjahr.
        zfexpense-budat   = ls_bsik-budat.
        zfexpense-bldat   = ls_bsik-bldat.
        zfexpense-dmbtr   = ls_bsik-dmbtr.
        zfexpense-sgtxt   = ls_bsik-sgtxt.
      ENDIF.

    WHEN '0811'.
      READ TABLE gt_yexp INTO ls_yexp INDEX tc_transaction-current_line.
      IF sy-subrc = 0.
        PERFORM f_dc_fr_type USING ls_yexp-bukrs ls_yexp-gtype ls_yexp-type
                             CHANGING ls_yexp-wrbtr.

        MOVE-CORRESPONDING ls_yexp TO zfexpense.
      ENDIF.

    WHEN '0812'.
      READ TABLE gt_yshp INTO ls_yshp INDEX tc_shipnew-current_line.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING ls_yshp TO zfshipment.
      ENDIF.

    WHEN '0813'.
      READ TABLE gt_yexp INTO ls_yexp INDEX tc_simtran-current_line.
      IF sy-subrc = 0.
        PERFORM f_dc_fr_type USING ls_yexp-bukrs ls_yexp-gtype ls_yexp-type
                             CHANGING ls_yexp-wrbtr.

        MOVE-CORRESPONDING ls_yexp TO zfexpense.
      ENDIF.

      READ TABLE gt_yshp INTO ls_yshp INDEX tc_simship-current_line.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING ls_yshp TO zfshipment.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " FILL_TABLE_CONTROL  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  VALIDASI_DATA  OUTPUT
*&---------------------------------------------------------------------*
MODULE validasi_data OUTPUT.

ENDMODULE.                 " VALIDASI_DATA  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  READ_TABLE_CONTROL  INPUT
*&---------------------------------------------------------------------*
MODULE read_table_control INPUT.
  DATA : lv_znopol      TYPE zf63masterkend-znopol,
         lv_keterangan  TYPE zf63masterkend-keterangan,
         ls_ship        LIKE LINE OF gt_ship,
         ls_mstk        LIKE LINE OF gt_mstk.

  CLEAR ls_mstk.
  CASE sy-dynnr.
    WHEN '0801'.
      ls_mstk       = zfmstken.
      READ TABLE gt_mstk INTO zfmstken INDEX tc_nopol-current_line.
      IF sy-subrc = 0.
        ls_mstk-loevm     = zfmstken-loevm.
        zfmstken          = ls_mstk.
      ELSE.
        CLEAR ls_mstk-loevm.
      ENDIF.

      IF zfmstken-buzei IS INITIAL.
        zfmstken-buzei = tc_nopol-current_line * 10.
      ENDIF.

      MODIFY gt_mstk FROM zfmstken INDEX tc_nopol-current_line.
      IF sy-subrc <> 0.
        zfmstken = ls_mstk.
        zfmstken-buzei = tc_nopol-current_line * 10.
        APPEND zfmstken TO gt_mstk.
      ENDIF.

      PERFORM f_validasi_data USING 'NOPOL' '' '' '' '' '' ''.

    WHEN '0802'.

    WHEN '0803'.
      ls_ship       = zfexpense.

      IF ls_ship-erdat IS INITIAL.
        SELECT SINGLE tknum erdat sttrg
          FROM vttk
          INTO (ls_ship-tknum, ls_ship-erdat, ls_ship-sttrg)
          WHERE tknum = zfexpense-tknum
            AND signi = zfexpense-znopol.
      ENDIF.

      IF sy-subrc = 0.
        PERFORM f_validasi_data USING 'TKNUM' '' '' '' '' '' ''.

        IF gv_error IS INITIAL.
          IF ls_ship-sttrg = '7'.
            ls_ship-status  = icon_green_light.
          ELSE.
            ls_ship-status  = icon_yellow_light.
          ENDIF.

          READ TABLE gt_ship INTO zfexpense INDEX tc_shipment-current_line.
          IF sy-subrc = 0.
            zfexpense   = ls_ship.
          ENDIF.

          IF zfexpense-name1 IS INITIAL.
            SELECT SINGLE name1
              FROM zf63masterperson
              INTO zfexpense-name1
              WHERE bukrs = zfexpense-bukrs
                AND vkbur = zfexpense-vkbur
                AND gsber = zfexpense-gsber
                AND gtype = zfexpense-gtype
                AND zidno = zfexpense-zidno.
          ENDIF.

          MODIFY gt_ship FROM zfexpense INDEX tc_shipment-current_line.
          IF sy-subrc <> 0.
            IF ls_ship-tknum IS NOT INITIAL.
              zfexpense = ls_ship.
              APPEND zfexpense TO gt_ship.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE s000(zab) WITH 'Shipment No.' zfexpense-tknum
                               'bukan untuk' zfexpense-znopol
                          DISPLAY LIKE 'E'.
        gv_error  = 'X'.
      ENDIF.

    WHEN '0804'.
      IF zfexpense-trf_hari IS NOT INITIAL.
        zfexpense-wrbtr = zfexpense-menge * zfexpense-trf_hari.
      ELSEIF zfexpense-trf_inap IS NOT INITIAL.
        zfexpense-wrbtr = zfexpense-menge * zfexpense-trf_inap.
      ENDIF.

      ls_expe       = zfexpense.

      READ TABLE gt_expe INTO zfexpense INDEX tc_expense-current_line.
      IF sy-subrc = 0.
        zfexpense   = ls_expe.
        MODIFY gt_final FROM ls_expe TRANSPORTING menge kmstr kmend vbund
                                                  trf_inap wrbtr text
                                     WHERE type  = zfexpense-type
                                       AND buzei = zfexpense-buzei.
      ENDIF.

      MODIFY gt_expe FROM zfexpense INDEX tc_expense-current_line.
      IF sy-subrc <> 0.
        zfexpense = ls_expe.
        APPEND zfexpense TO gt_expe.
      ENDIF.

      PERFORM f_validasi_data USING 'KM' zfexpense-kmstr zfexpense-kmend
                                    '' '' '' ''.
      PERFORM f_validasi_data USING 'OBLIGATORY'
                                    zfexpense-kmstr
                                    zfexpense-kmend
                                    zfexpense-menge
                                    zfexpense-type
                                    zfexpense-wrbtr
                                    zfexpense-description.
      PERFORM f_validasi_data USING 'VBUND' '' '' '' '' '' ''.

    WHEN '0806'.
      READ TABLE gt_bsik INTO ls_bsik INDEX tc_advance-current_line.
      IF sy-subrc = 0.
        IF zfexpense-mark IS NOT INITIAL.
          gv_belnr  = ls_bsik-belnr.
          gv_gjahr  = ls_bsik-gjahr.
          gv_dmbtr  = ls_bsik-dmbtr.
          gv_hkont  = ls_bsik-hkont.
          CONCATENATE zfexpense-sgtxt '-' zfexpense-zuonr ',' ls_bsik-belnr
          INTO gv_description
          SEPARATED BY space.
          SELECT SINGLE bktxt
            FROM bkpf
            INTO gv_bktxt
            WHERE bukrs = pa_bukrs
              AND belnr = gv_belnr
              AND gjahr = gv_gjahr.
        ENDIF.
      ENDIF.

    WHEN '0810'.
      READ TABLE gt_bsik INTO ls_bsik INDEX tc_advance-current_line.
      IF sy-subrc = 0.
        IF zfexpense-mark1 IS NOT INITIAL.
          gv_belnr  = ls_bsik-belnr.
          gv_gjahr  = ls_bsik-gjahr.
          gv_dmbtr  = ls_bsik-dmbtr.
          gv_hkont  = ls_bsik-hkont.
          CONCATENATE zfexpense-sgtxt '-' zfexpense-zuonr ',' ls_bsik-belnr
          INTO gv_description
          SEPARATED BY space.
          SELECT SINGLE bktxt
            FROM bkpf
            INTO gv_bktxt
            WHERE bukrs = pa_bukrs
              AND belnr = gv_belnr
              AND gjahr = gv_gjahr.
        ENDIF.
      ENDIF.

    WHEN '0811'.
      READ TABLE gt_yexp INTO ls_yexp INDEX tc_transaction-current_line.
      IF zfexpense-mark IS NOT INITIAL.
        ls_yexp-icon = icon_delete.
        MODIFY gt_yexp FROM ls_yexp
                       INDEX tc_transaction-current_line
                       TRANSPORTING icon.
      ENDIF.

    WHEN '0812'.
      ls_yshp-tknum  = zfshipment-tknum.
      ls_yshp-erdat  = zfshipment-erdat.
      ls_yshp-sttrg  = zfshipment-sttrg.
      IF zfshipment-tknum IS INITIAL.
        DELETE gt_yshp INDEX tc_shipnew-current_line.
      ELSE.
        MODIFY gt_yshp FROM ls_yshp INDEX tc_shipnew-current_line.
      ENDIF.
      IF sy-subrc <> 0.
        APPEND ls_yshp TO gt_yshp.
      ENDIF.
      CLEAR ls_yshp.
  ENDCASE.
ENDMODULE.                 " READ_TABLE_CONTROL  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND   INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  DATA : char(1).

  DATA : fnam(30), fval(50),
         lv_belnr    TYPE bseg-belnr,
         lv_gjahr    TYPE bseg-gjahr,
         lv_budat    TYPE bkpf-budat,
         ls_bkpf     LIKE LINE OF gt_bkpf,
         ls_bseg     LIKE LINE OF gt_bseg,
         ls_ctrladv  LIKE LINE OF gt_ctrladv.

  DATA : ls_trnhdr    LIKE LINE OF gt_trnhdr,
         ls_trndtl    LIKE LINE OF gt_trndtl,
         ls_trnhdr2   LIKE LINE OF gt_trnhdr2.

  DATA : lt_trnhdr    TYPE STANDARD TABLE OF zf63trnhdr
                      INITIAL SIZE 0,
         lv_perid     TYPE zf63masterperson-zidno.

  DATA : ls_acc       LIKE LINE OF gt_zf63acc,
         lv_shkzg     TYPE bseg-shkzg,
         lv_multi.

  DATA : lt_mstp      TYPE STANDARD TABLE OF ty_mstp,
         lt_xvttk     TYPE STANDARD TABLE OF vttk,
         ls_xvttk     LIKE LINE OF lt_xvttk,
         ls_biaya     LIKE LINE OF gt_biaya.

  CASE ok_code.
    WHEN 'CLIP'.
      CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
        EXPORTING
          functioncode           = ok_code
        EXCEPTIONS
          function_not_supported = 1
          OTHERS                 = 2.
      CLEAR : ok_code, sy-ucomm.

    WHEN 'BACK' OR 'CANC' OR 'EXIT'.
      CASE sy-dynnr.
        WHEN '0803'.

        WHEN '0804'.
          LOOP AT gt_expe INTO ls_expe.
            CLEAR ls_save.
            IF ls_expe-wrbtr IS INITIAL .
              DELETE gt_save WHERE type  = ls_expe-type
                               AND buzei = ls_expe-buzei.
              CONTINUE.
            ENDIF.

            READ TABLE gt_save INTO ls_save WITH KEY type  = ls_expe-type
                                                     buzei = ls_expe-buzei.
            IF sy-subrc <> 0.
              ls_save = ls_expe.
              ls_save-type   = ls_expe-type.
              APPEND ls_save TO gt_save.
            ENDIF.
            CLEAR ls_expe.
          ENDLOOP.

          IF gt_save[] IS INITIAL.
            LEAVE TO SCREEN 0.
          ENDIF.

          IF ok_code = 'CANC' OR
            ok_code = 'EXIT'.
            LEAVE TO SCREEN 0.
          ENDIF.

        WHEN '0805'.
          IF ok_code = 'CANC' OR
            ok_code = 'EXIT'.
            LEAVE TO SCREEN 0.
          ENDIF.

        WHEN '0806'.
          CLEAR : zfexpense-wrbtr.
          LEAVE TO SCREEN 0.

        WHEN '0807'.
          LEAVE TO SCREEN 0.

        WHEN '0808'.
          gv_subrc  = 4.
          LEAVE TO SCREEN 0.

        WHEN '0809'.
          LEAVE TO SCREEN 0.

        WHEN OTHERS.
          IF char <> 'N'.
            LEAVE TO SCREEN 0.
          ENDIF.
      ENDCASE.

*---- New for ZF63N
    WHEN 'PREV'.
      CASE sy-dynnr.
        WHEN '0805'.
          PERFORM f_prepare_detail CHANGING lv_shkzg.
          PERFORM f_print_form_new USING 'ZFEXP_F001' 'PREV' 'X'
                                   CHANGING lv_shkzg.
        WHEN '0813'.
          PERFORM f_prepare_data USING '813'.
          PERFORM f_move_to_smartforms.
          PERFORM f_print_form_new USING 'ZFEXP_F001N' 'PREV' ''
                                   CHANGING lv_shkzg.
          CLEAR : gt_trndtl2[], gt_trnhdr2[], gs_header, gt_window3[], gt_detail[].
      ENDCASE.
*-----

    WHEN 'SAVE'.
      CASE sy-dynnr.
        WHEN '0804'.
          IF gv_error IS INITIAL.
            PERFORM f_prepare_data USING '805'.
            SET SCREEN 805.
          ENDIF.

        WHEN '0805'.
          IF gv_error IS INITIAL.
            CASE 'X'.
              WHEN radio4.
                PERFORM f_save_data.
              WHEN radio14.
                CASE sy-tcode.
                  WHEN 'ZF63B'.
                    PERFORM f_save_data.
                  WHEN 'ZF63N'.
                    PERFORM f_prepare_detail CHANGING lv_shkzg.

                    PERFORM f_print_form_new USING 'ZFEXP_F001' 'PRNT' 'X'
                                             CHANGING lv_shkzg.

                    IF gv_kdvch IS NOT INITIAL.
                      PERFORM f_modify_nomor USING pa_bukrs pa_vkbur
                                                   'H' gv_kdvch gv_nmvch
                                                   sy-datum(6) gv_nomor.

                      PERFORM f_save_data.
                    ELSE.
                      CALL FUNCTION 'DEQUEUE_ALL'.
                      MESSAGE s000(zab) WITH 'No Voucher belum dimaintain'
                                        DISPLAY LIKE 'E'.
                    ENDIF.
                ENDCASE.

                LEAVE TO SCREEN 0.
            ENDCASE.
          ENDIF.

        WHEN '0813'.
          PERFORM f_prepare_data USING '813'.
          PERFORM f_move_to_smartforms.
          PERFORM f_print_form_new USING 'ZFEXP_F001N' 'PRNT' ''
                                   CHANGING lv_shkzg.
          PERFORM f_save_data.
          CLEAR : gt_trndtl2[], gt_trnhdr2[], gs_header, gt_window3[], gt_detail[].
          LEAVE TO SCREEN 0.

        WHEN OTHERS.
          IF gv_error IS INITIAL.
            PERFORM f_save_data.
          ENDIF.
      ENDCASE.

    WHEN '&DEL'.
      PERFORM f_delete_data.

    WHEN '&REFR'.
      CLEAR : zftransaction.

    WHEN 'CONT'.
      CASE sy-dynnr.
        WHEN '0806'.
          READ TABLE gt_zf63acc INTO ls_acc
                                WITH KEY ktext = zfexpense-ktext.
          IF sy-subrc = 0.
            PERFORM f_alpha_conversion USING ls_acc-hkont
                                       CHANGING zfexpense-hkont.
          ELSE.
            gv_error  = selected.
            MESSAGE s000(zab) WITH 'GL Account Cash/Bank salah'
                              DISPLAY LIKE 'E'.
          ENDIF.

          IF zfexpense-advance IS NOT INITIAL.
            IF gv_belnr IS INITIAL.
              MESSAGE s000(zab) WITH 'Penyelesaian advance belum dipilih'
              DISPLAY LIKE 'E'.
            ELSE.
              PERFORM f_cek_hkont USING zfexpense-hkont
                                  CHANGING lv_subrc.
              IF sy-subrc = 0.
                LEAVE TO SCREEN 0.
              ELSE.
                gv_error  = selected.
                MESSAGE s000(zab) WITH 'GL Account Cash/Bank salah' DISPLAY LIKE 'E'.
              ENDIF.
            ENDIF.
          ELSE.
            PERFORM f_cek_hkont USING zfexpense-hkont
                                CHANGING lv_subrc.
            IF sy-subrc = 0.
              LEAVE TO SCREEN 0.
            ELSE.
              gv_error  = selected.
              MESSAGE s000(zab) WITH 'GL Account Cash/Bank salah' DISPLAY LIKE 'E'.
            ENDIF.
          ENDIF.

          PERFORM f_cek_hkont USING zfexpense-hkont
                              CHANGING lv_subrc.
          IF sy-subrc = 0.
            LEAVE TO SCREEN 0.
          ELSE.
            gv_error  = selected.
            MESSAGE s000(zab) WITH 'GL Account Cash/Bank salah' DISPLAY LIKE 'E'.
          ENDIF.

        WHEN '0807'.
          PERFORM f_validasi_reverse_document CHANGING gv_reverse.

        WHEN '0809'.
          IF radio17 IS NOT INITIAL.
            CLEAR ls_trnhdr2.
            READ TABLE gt_trnhdr2 INTO ls_trnhdr2 INDEX 1.
            IF sy-subrc = 0.
              PERFORM f_prepare_cancel_data USING ls_trnhdr2.
              PERFORM f_simulate USING ls_trnhdr2.
            ENDIF.
            LEAVE TO SCREEN 0.
          ELSE.
            PERFORM f_check_vbund USING zfexpense-vbund
                                  CHANGING lv_subrc.
            IF lv_subrc = 0.
              gv_execute  = selected.
              gs_trndtl-vbund = zfexpense-vbund.
              gs_trndtl-text  = zfexpense-text.
              MODIFY gt_trndtl FROM gs_trndtl
                               INDEX gv_tabix
                               TRANSPORTING vbund text.
              LEAVE TO SCREEN 0.
            ELSE.
              LOOP AT gt_trndtl INTO ls_trndtl.
                READ TABLE gt_typeexp INTO ls_typeexp
                                      WITH KEY bukrs = ls_trndtl-bukrs
                                               gtype = ls_trndtl-gtype
                                               type  = ls_trndtl-type.
                IF sy-subrc = 0.
                  IF ls_typeexp-zvbund IS NOT INITIAL.
                    gv_error = selected.
                    MESSAGE i000(zab) WITH 'Trading Partner salah'
                                      DISPLAY LIKE 'E'.
                  ENDIF.
                ENDIF.
              ENDLOOP.
              IF gv_error IS INITIAL.
                gv_execute  = selected.
                LEAVE TO SCREEN 0.
              ENDIF.
            ENDIF.
          ENDIF.

        WHEN '0812'.
          IF gt_yshp[] IS NOT INITIAL.
            SELECT tknum erdat sttrg
              FROM vttk
              INTO CORRESPONDING FIELDS OF TABLE lt_xvttk
              FOR ALL ENTRIES IN gt_yshp
              WHERE tknum = gt_yshp-tknum
                AND signi = zfexpense-znopol.
          ENDIF.

          LOOP AT gt_yshp INTO ls_yshp.
            ls_xshp = ls_yshp.
            ls_xshp-znopol = zfexpense-znopol.
            CLEAR ls_xvttk.
            READ TABLE lt_xvttk INTO ls_xvttk
                                WITH KEY tknum = ls_yshp-tknum.
            IF sy-subrc = 0.
              ls_xshp-erdat = ls_xvttk-erdat.
              ls_xshp-sttrg = ls_xvttk-sttrg.
              MODIFY gt_xshp FROM ls_xshp
                     TRANSPORTING erdat sttrg
                            WHERE znopol = zfexpense-znopol
                              AND tknum  = ls_yshp-tknum.
              IF sy-subrc <> 0.
                APPEND ls_xshp TO gt_xshp.
              ENDIF.
            ENDIF.
            CLEAR : ls_xshp.
          ENDLOOP.
          CLEAR : gt_yshp[], gt_yshp.
          LEAVE TO SCREEN 0.
      ENDCASE.

    WHEN '&REVDO'.
      IF gv_reverse IS NOT INITIAL.
        LOOP AT gt_bkpf INTO ls_bkpf.
          CALL FUNCTION 'CALL_FB08'
            EXPORTING
              i_bukrs      = pa_bukrs
              i_belnr      = ls_bkpf-belnr
              i_gjahr      = ls_bkpf-gjahr
              i_stgrd      = uf05a-stgrd
              i_budat      = bsis-budat
            IMPORTING
              e_budat      = lv_budat
            EXCEPTIONS
              not_possible = 1
              OTHERS       = 2.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = sy-msgv1
            IMPORTING
              output = lv_belnr.

          CASE ls_bkpf-blart.
            WHEN 'SA'.
              CASE sy-tcode.
                WHEN 'ZF63B'.
                  UPDATE zf63trnvch SET gjahrrev = lv_budat(4)
                                        belnrrev = lv_belnr
                                        budatrev = lv_budat
                                        userrev  = sy-uname
                                        tglrev   = sy-datum
                                        jamrev   = sy-uzeit
                                    WHERE bukrs = pa_bukrs
                                      AND gsber = pa_gsber
                                      AND vkbur = pa_vkbur
                                      AND gtype = pa_gtype
                                      AND zidvc = pa_zidvc
                                      AND vjahr = pa_vjahr.
                WHEN 'ZF63N'.
                  UPDATE zf63trnhdr2 SET gjahrpexprev = lv_budat(4)
                                         belnrpexprev = lv_belnr
                                         budatpexprev = lv_budat
                                         userrev      = sy-uname
                                         tglrev       = sy-datum
                                         jamrev       = sy-uzeit
                                    WHERE bukrs = pa_bukrs
                                      AND gsber = pa_gsber
                                      AND vkbur = pa_vkbur
                                      AND gtype = pa_gtype
                                      AND zidvc = pa_zidv2
                                      AND gjahr = pa_vjahr.
              ENDCASE.

            WHEN 'KZ'.
              CASE sy-tcode.
                WHEN 'ZF63B'.
                  READ TABLE gt_bseg INTO ls_bseg
                                     WITH KEY bukrs = pa_bukrs
                                              belnr = ls_bkpf-belnr
                                              gjahr = ls_bkpf-gjahr
                                              koart = 'K'.
                  IF sy-subrc = 0.
                    READ TABLE gt_trnhdr INTO ls_trnhdr INDEX 1.
                    IF sy-subrc = 0.
                      CLEAR ls_ctrladv.
                      IF gs_gtype-advance IS INITIAL.
                        SELECT SINGLE *
                          FROM zf63ctrladv
                          INTO CORRESPONDING FIELDS OF ls_ctrladv
                          WHERE bukrs   = ls_trnhdr-bukrs
                            AND vkbur   = ls_trnhdr-vkbur
                            AND gtype   = gs_gtype-jeadv
                            AND lifnr   = ls_bseg-lifnr
                            AND zidno   = ls_trnhdr-zidno.
*                            AND gjahr   = ls_trnhdr-gjahr.
                      ELSE.
                        SELECT SINGLE zidno
                          FROM zf63masterperson
                          INTO lv_perid
                          WHERE bukrs = ls_trnhdr-bukrs
                            AND gsber = ls_trnhdr-vkbur
                            AND vkbur = ls_trnhdr-vkbur
                            AND lifnr = ls_trnhdr-zidno.

                        SELECT SINGLE *
                          FROM zf63ctrladv
                          INTO CORRESPONDING FIELDS OF ls_ctrladv
                          WHERE bukrs   = ls_trnhdr-bukrs
                            AND vkbur   = ls_trnhdr-vkbur
                            AND gtype   = ls_trnhdr-gtype
                            AND lifnr   = ls_trnhdr-zidno
                            AND zidno   = lv_perid.
*                            AND gjahr   = ls_trnhdr-gjahr.
                      ENDIF.
                    ENDIF.
                  ENDIF.

                  UPDATE zf63trnvch SET gjahrpadvrev = lv_budat(4)
                                        belnrpadvrev = lv_belnr
                                        budatpadvrev = lv_budat
                                        userrev      = sy-uname
                                        tglrev       = sy-datum
                                        jamrev       = sy-uzeit
                                    WHERE bukrs = pa_bukrs
                                      AND gsber = pa_gsber
                                      AND vkbur = pa_vkbur
                                      AND gtype = pa_gtype
                                      AND zidvc = pa_zidvc
                                      AND vjahr = pa_vjahr.

                WHEN 'ZF63N'.
                  READ TABLE gt_bseg INTO ls_bseg
                                     WITH KEY bukrs = pa_bukrs
                                              belnr = ls_bkpf-belnr
                                              gjahr = ls_bkpf-gjahr
                                              koart = 'K'.
                  IF sy-subrc = 0.
                    READ TABLE gt_trnhdr2 INTO ls_trnhdr2 INDEX 1.
                    IF sy-subrc = 0.
                      CLEAR ls_ctrladv.
                      IF gs_gtype-advance IS INITIAL.
                        SELECT SINGLE *
                          FROM zf63ctrladv
                          INTO CORRESPONDING FIELDS OF ls_ctrladv
                          WHERE bukrs   = ls_trnhdr2-bukrs
                            AND vkbur   = ls_trnhdr2-vkbur
                            AND gtype   = gs_gtype-jeadv
                            AND lifnr   = ls_bseg-lifnr
                            AND zidno   = ls_trnhdr2-zidno.
*                            AND gjahr   = ls_trnhdr2-gjahr.
                      ELSE.
                        SELECT SINGLE zidno
                          FROM zf63masterperson
                          INTO lv_perid
                          WHERE bukrs = ls_trnhdr2-bukrs
                            AND gsber = ls_trnhdr2-vkbur
                            AND vkbur = ls_trnhdr2-vkbur
                            AND lifnr = ls_trnhdr2-zidno.

                        SELECT SINGLE *
                          FROM zf63ctrladv
                          INTO CORRESPONDING FIELDS OF ls_ctrladv
                          WHERE bukrs   = ls_trnhdr2-bukrs
                            AND vkbur   = ls_trnhdr2-vkbur
                            AND gtype   = ls_trnhdr2-gtype
                            AND lifnr   = ls_trnhdr2-zidno
                            AND zidno   = lv_perid.
*                            AND gjahr   = ls_trnhdr2-gjahr.
                      ENDIF.
                    ENDIF.
                  ENDIF.

                  UPDATE zf63trnhdr2 SET gjahrpadvrev = lv_budat(4)
                                         belnrpadvrev = lv_belnr
                                         budatpadvrev = lv_budat
                                         userrev      = sy-uname
                                         tglrev       = sy-datum
                                         jamrev       = sy-uzeit
                                    WHERE bukrs = pa_bukrs
                                      AND gsber = pa_gsber
                                      AND vkbur = pa_vkbur
                                      AND gtype = pa_gtype
                                      AND zidvc = pa_zidv2
                                      AND gjahr = pa_vjahr.
              ENDCASE.
          ENDCASE.
        ENDLOOP.

        LOOP AT gt_trnhdr INTO ls_trnhdr.
          UPDATE zf63kmhexph SET lvorm = selected
                             WHERE expnr = ls_trnhdr-expnr.
        ENDLOOP.

        IF gs_gtype-advance IS INITIAL.
          ls_ctrladv-zreal  = ls_ctrladv-zreal - 1.
          IF ls_ctrladv-zreal < 0.
            ls_ctrladv-zreal = 0.
          ENDIF.
        ELSE.
          ls_ctrladv-advan  = ls_ctrladv-advan - 1.
          IF ls_ctrladv-advan < 0.
            ls_ctrladv-advan = 0.
          ENDIF.
        ENDIF.
        UPDATE zf63ctrladv FROM ls_ctrladv.

        LEAVE TO SCREEN 0.
      ELSE.
        MESSAGE s000(zab) WITH 'Validate data first'
                          DISPLAY LIKE 'E'.
      ENDIF.

    WHEN 'PICK'.
      CASE sy-dynnr.
        WHEN '0807'.
          GET CURSOR FIELD fnam VALUE fval.
          CASE fnam.
            WHEN 'ZF63REVERSE-BELNR'.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = fval
                IMPORTING
                  output = lv_belnr.
              lv_gjahr  = zf63reverse-gjahr.
            WHEN 'ZF63REVERSE-BELNRPADV'.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = fval
                IMPORTING
                  output = lv_belnr.
              lv_gjahr  = zf63reverse-gjahrpadv.
          ENDCASE.

          SET PARAMETER ID 'BLN' FIELD lv_belnr.
          SET PARAMETER ID 'BUK' FIELD pa_bukrs.
          SET PARAMETER ID 'GJR' FIELD lv_gjahr.
          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDCASE.

    WHEN 'MORE'.
      CASE 'X'.
        WHEN radio15.
          IF zfexpense-advance IS NOT INITIAL.
            IF gv_belnr IS INITIAL.
              MESSAGE s000(zab) WITH 'Penyelesaian advance belum dipilih'
              DISPLAY LIKE 'E'.
            ELSE.
              CALL SCREEN 811.
              IF sy-ucomm = 'PRNT'.
                LEAVE TO SCREEN 0.
              ENDIF.
              LEAVE TO SCREEN 0.
            ENDIF.
          ELSE.
            CALL SCREEN 811.
            IF sy-ucomm = 'PRNT'.
              LEAVE TO SCREEN 0.
            ENDIF.
          ENDIF.

        WHEN OTHERS.
          CLEAR gv_xbkt.
          IF radio14 IS NOT INITIAL.
            PERFORM f_counter_advance.
          ENDIF.

          IF gv_error IS INITIAL.
            PERFORM f_prepare_data USING '804'.
            PERFORM f_call_screen_804.
          ELSE.
            IF radio14 IS NOT INITIAL.
              MESSAGE s000(zab) WITH 'Sudah tidak bisa melakukan advance'
              DISPLAY LIKE 'E'.
            ENDIF.
          ENDIF.
      ENDCASE.

    WHEN '&SHP'.
      CALL SCREEN 812 STARTING AT 10 10.

    WHEN '&ADDL'.
      CLEAR lv_multi.
      IF ls_tyexpdtl-zpercen IS INITIAL.
        IF zftransaction-departemen IS INITIAL.
*          MESSAGE s000(zab) WITH 'Fill in all required entry fields'
*          DISPLAY LIKE 'E'.
          gv_depar = 'X'.
        ENDIF.
      ELSE.
        READ TABLE gt_biaya INTO ls_biaya
                            WITH KEY type = zftransaction-type.
        IF sy-subrc = 0.
          lv_multi  = 'X'.
        ENDIF.
      ENDIF.

      IF gv_depar IS INITIAL.
        MOVE-CORRESPONDING zfexpense TO ls_xexp.
        MOVE-CORRESPONDING zftransaction TO ls_xexp.
        IF lv_multi IS NOT INITIAL.
          LOOP AT gt_biaya INTO ls_biaya WHERE type = zftransaction-type.
            ls_xexp-znopol     = zfexpense-znopol.
            ls_xexp-departemen = ls_biaya-departemen.
            ls_xexp-percentage = ls_biaya-percentage.
            ls_xexp-wrbtr      = zftransaction-wrbtr * ls_biaya-percentage.
            APPEND ls_xexp TO gt_xexp.

            PERFORM f_profit_seqment TABLES gt_kostl
                                     USING ls_biaya-vkbur ls_biaya-departemen.
          ENDLOOP.
        ELSE.
          ls_xexp-znopol = zfexpense-znopol.
          APPEND ls_xexp TO gt_xexp.

          PERFORM f_profit_seqment TABLES gt_kostl
                                   USING zfexpense-vkbur zftransaction-departemen.
        ENDIF.
        CLEAR : ls_xexp, zftransaction.
      ENDIF.
      CLEAR gv_depar.

    WHEN '&DELL'.
      DELETE gt_xexp WHERE znopol = zfexpense-znopol.
      LOOP AT gt_yexp INTO ls_yexp.
        ls_xexp = ls_yexp.
        APPEND ls_xexp TO gt_xexp.
        CLEAR ls_xexp.
      ENDLOOP.

    WHEN '&ADD'.
      CLEAR : zfexpense-znopol, zftransaction.

    WHEN '&SIM'.
      CALL SCREEN 813.
      IF sy-ucomm = 'PRNT'.
        LEAVE TO SCREEN 0.
      ENDIF.

    WHEN OTHERS.
      CASE sy-dynnr.
        WHEN '0802'.
          IF zfmstper-lifnr IS NOT INITIAL.
            PERFORM f_get_description USING 'LFA1' 'NAME1' 'LIFNR'
                                            zfmstper-lifnr
                                      CHANGING zfexpense-lifnr_name1.
          ENDIF.

        WHEN '0803'.

        WHEN '0804'.
          IF gv_error IS INITIAL.
            PERFORM f_prepare_data USING '804'.
            PERFORM f_call_screen_804.
          ENDIF.

        WHEN '0805'.
          IF gv_error IS INITIAL.
            CLEAR : zfexpense-wrbtr, zfexpense-text.
            PERFORM f_prepare_data USING '804'.
            PERFORM f_call_screen_804.
          ENDIF.

        WHEN '0806'.
          IF zfexpense-ktext IS NOT INITIAL.
            READ TABLE gt_zf63acc INTO ls_acc
                                  WITH KEY ktext = zfexpense-ktext.
            IF sy-subrc = 0.
              PERFORM f_alpha_conversion USING ls_acc-hkont
                                         CHANGING zfexpense-hkont.
            ENDIF.

            PERFORM f_cek_hkont USING zfexpense-hkont
                                CHANGING lv_subrc.
            IF sy-subrc <> 0.
              MESSAGE s000(zab) WITH 'GL Account Cash/Bank salah'
              DISPLAY LIKE 'E'.
            ENDIF.
          ENDIF.

        WHEN '0808'.
          IF gs_gtype-advance IS NOT INITIAL.
            READ TABLE gt_zf63acc INTO ls_acc
                                  WITH KEY ktext = zfexpense-ktext.
            IF sy-subrc = 0.
              PERFORM f_alpha_conversion USING ls_acc-hkont
                                         CHANGING zfexpense-hkont.
            ENDIF.

            PERFORM f_cek_hkont USING zfexpense-hkont
                                CHANGING lv_subrc.
            IF sy-subrc = 0.
              LEAVE TO SCREEN 0.
            ELSE.
              MESSAGE s000(zab) WITH 'GL Account Cash/Bank salah' DISPLAY LIKE 'E'.
            ENDIF.
          ELSE.
            LEAVE TO SCREEN 0.
          ENDIF.

        WHEN '0810'.
          IF gs_gtype-advance IS INITIAL.
            SELECT *
              FROM zf63masterperson
              INTO CORRESPONDING FIELDS OF TABLE gt_mstp
              WHERE bukrs = pa_bukrs
                AND gsber = pa_gsber
                AND vkbur = pa_vkbur
                AND zidno = zfexpense-zidno.
          ELSE.
            SELECT *
              FROM zf63masterperson
              INTO CORRESPONDING FIELDS OF TABLE gt_mstp
              WHERE bukrs = pa_bukrs
                AND gsber = pa_gsber
                AND vkbur = pa_vkbur
                AND lifnr = zfexpense-zidno.
          ENDIF.

          lt_mstp[] = gt_mstp[].
          SORT lt_mstp BY lifnr.
          DELETE ADJACENT DUPLICATES FROM lt_mstp COMPARING lifnr.

          LOOP AT lt_mstp INTO ls_mstp.
            PERFORM f_get_bsik USING pa_bukrs ls_mstp-lifnr 'C'
                                     '' '' pa_gsber 'X'.
          ENDLOOP.

        WHEN '0812'.
          IF gt_yshp[] IS NOT INITIAL.
            SELECT tknum erdat sttrg
              FROM vttk
              INTO CORRESPONDING FIELDS OF TABLE lt_xvttk
              FOR ALL ENTRIES IN gt_yshp
              WHERE tknum = gt_yshp-tknum
                AND signi = zfexpense-znopol.
          ENDIF.

          LOOP AT gt_yshp INTO ls_yshp.
            ls_xshp = ls_yshp.
            ls_xshp-znopol = zfexpense-znopol.
            CLEAR ls_xvttk.
            READ TABLE lt_xvttk INTO ls_xvttk
                                WITH KEY tknum = ls_yshp-tknum.
            IF sy-subrc = 0.
              ls_xshp-erdat = ls_xvttk-erdat.
              ls_xshp-sttrg = ls_xvttk-sttrg.
              MODIFY gt_xshp FROM ls_xshp
                      TRANSPORTING erdat sttrg
                             WHERE znopol = zfexpense-znopol
                               AND tknum = ls_yshp-tknum.
              IF sy-subrc <> 0.
                APPEND ls_xshp TO gt_xshp.
              ENDIF.
            ENDIF.
            CLEAR : ls_xshp.
          ENDLOOP.
          CLEAR : gt_yshp[], gt_yshp.
      ENDCASE.
  ENDCASE.

  CLEAR : ok_code, gv_error.
ENDMODULE.                 " USER_COMMAND   INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_ZIDKE  INPUT
*&---------------------------------------------------------------------*
MODULE value_zidke INPUT.
  DATA : return_tab     TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return      LIKE LINE OF return_tab.

  DATA : BEGIN OF lt_kend OCCURS 0,
           zidke   TYPE zf63masterkend-zidke,
           znopol  TYPE zf63masterkend-znopol,
         END OF lt_kend.

  CLEAR : lt_kend[], lt_kend, dynpfields[], dynpfields.
  LOOP AT gt_mstk INTO ls_mstk.
    lt_kend-zidke   = ls_mstk-zidke.
    lt_kend-znopol  = ls_mstk-znopol.
    APPEND lt_kend.
  ENDLOOP.

  ASSIGN lt_kend[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'ZIDKE' 'ZFMSTPER-ZIDKER'
                          CHANGING lv_subrc.
  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      lt_kend-zidke  = ls_return-fieldval.
      PERFORM f_read_master_kendaraan USING lt_kend-zidke 'X'.

      PERFORM f_dynpfield TABLES dynpfields
                          USING 'ZFMSTPER-KOSTL' zfmstper-kostl ''.
      IF gs_mstp-ktext IS INITIAL.
        PERFORM f_get_description USING 'CSKT' 'KTEXT' 'KOSTL'
                                        zfmstper-kostl
                                  CHANGING gs_mstp-ktext.
      ENDIF.
      PERFORM f_dynpfield TABLES dynpfields
                          USING 'GS_MSTP-KTEXT' gs_mstp-ktext ''.

      PERFORM f_dynpfield TABLES dynpfields
                          USING 'ZFMSTPER-WWSFR' zfmstper-wwsfr ''.
      IF gs_mstp-bezeksfr IS INITIAL.
        PERFORM f_get_description USING 'T25A5' 'BEZEK' 'WWSFR'
                                        zfmstper-wwsfr
                                  CHANGING gs_mstp-bezeksfr.
      ENDIF.
      PERFORM f_dynpfield TABLES dynpfields
                          USING 'GS_MSTP-BEZEKFSR' gs_mstp-bezeksfr ''.

      PERFORM f_dynpfield TABLES dynpfields
                          USING 'ZFMSTPER-WWPOS' zfmstper-wwpos ''.
      IF gs_mstp-bezekpos IS INITIAL.
        PERFORM f_get_description USING 'T25A8' 'BEZEK' 'WWPOS'
                                        zfmstper-wwpos
                                  CHANGING gs_mstp-bezekpos.
      ENDIF.
      PERFORM f_dynpfield TABLES dynpfields
                          USING 'GS_MSTP-BEZEKPOS' gs_mstp-bezekpos ''.

      PERFORM f_dynpfield TABLES dynpfields
                          USING 'ZFMSTPER-VBUND' zfmstper-vbund ''.
      IF gs_mstp-name1tp IS INITIAL.
        PERFORM f_get_description USING 'T880' 'NAME1' 'RCOMP'
                                        zfmstper-vbund
                                  CHANGING gs_mstp-name1tp.
      ENDIF.
      PERFORM f_dynpfield TABLES dynpfields
                          USING 'GS_MSTP-NAME1TP' gs_mstp-name1tp ''.

      PERFORM f_modify_screen USING : 'KOS' '' gv_input '' ''.
      PERFORM f_modify_screen USING : 'SFR' '' gv_input '' ''.
      PERFORM f_modify_screen USING : 'POS' '' gv_input '' ''.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALUE_ZIDKE  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_PERNR  INPUT
*&---------------------------------------------------------------------*
MODULE value_pernr INPUT.
  TYPES : BEGIN OF ty_pa0001,
           pernr   TYPE pa0001-pernr,
           sname   TYPE pa0001-sname,
         END OF ty_pa0001.

  DATA : lt_pa0001  TYPE STANDARD TABLE OF ty_pa0001 INITIAL SIZE 0,
         ls_pa0001  LIKE LINE OF lt_pa0001,
         lv_pernr   TYPE pa0001-pernr.

  CLEAR : lt_pa0001[], lt_pa0001, dynpfields[], dynpfields.
  SELECT *
    FROM pa0001
    INTO CORRESPONDING FIELDS OF TABLE lt_pa0001
    WHERE bukrs = zfmstper-bukrs
      AND gsber = zfmstper-gsber
      AND endda >= sy-datum
      AND begda <= sy-datum.

  ASSIGN lt_pa0001[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'PERNR' 'ZFMSTPER-PERNR'
                          CHANGING lv_subrc.
  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      lv_pernr  = ls_return-fieldval.
      READ TABLE lt_pa0001 INTO ls_pa0001 WITH KEY pernr = lv_pernr.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFMSTPER-PERNR' ls_pa0001-pernr ''.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFEXPENSE-PERNR_NAME1'
                                  ls_pa0001-sname ''.
      ENDIF.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALUE_PERNR  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_LIFNR  INPUT
*&---------------------------------------------------------------------*
MODULE value_lifnr INPUT.
  TYPES : BEGIN OF ty_lfa1,
            lifnr   TYPE lfa1-lifnr,
            name1   TYPE lfa1-name1,
            sortl   TYPE lfa1-sortl,
          END OF ty_lfa1.

  DATA : lt_lfa1    TYPE STANDARD TABLE OF ty_lfa1 INITIAL SIZE 0,
         ls_lfa1    LIKE LINE OF lt_lfa1,
         lv_lifnr   TYPE lfa1-lifnr.

  CLEAR : lt_lfa1[], lt_lfa1, dynpfields[], dynpfields.
  SELECT lfa1~lifnr name1 sortl
    FROM lfa1 JOIN lfb1 ON lfa1~lifnr = lfb1~lifnr
    INTO CORRESPONDING FIELDS OF TABLE lt_lfa1
    WHERE bukrs = zfmstper-bukrs
      AND ktokk = 'EMPL'.

  ASSIGN lt_lfa1[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'LIFNR' 'ZFMSTPER-LIFNR'
                          CHANGING lv_subrc.
  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      PERFORM f_alpha_conversion USING ls_return-fieldval
                                 CHANGING lv_lifnr.
      READ TABLE lt_lfa1 INTO ls_lfa1 WITH KEY lifnr = lv_lifnr.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFMSTPER-LIFNR' ls_lfa1-lifnr ''.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFEXPENSE-LIFNR_NAME1'
                                  ls_lfa1-name1 ''.
      ENDIF.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALUE_LIFNR  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_KUNNR  INPUT
*&---------------------------------------------------------------------*
MODULE value_kunnr INPUT.
  TYPES : BEGIN OF ty_kna1,
            kunnr   TYPE kna1-kunnr,
            name1   TYPE kna1-name1,
         END OF ty_kna1.

  DATA : lt_kna1    TYPE STANDARD TABLE OF ty_kna1,
         ls_kna1    LIKE LINE OF lt_kna1,
         lv_kunnr   TYPE kna1-kunnr.

  DATA : lr_kunnr   TYPE RANGE OF kunnr,
         ls_kunnr   LIKE LINE OF lr_kunnr.

  ls_kunnr-low    = 'CV*'.
  ls_kunnr-sign   = 'I'.
  ls_kunnr-option = 'CP'.
  APPEND ls_kunnr TO lr_kunnr.

  CLEAR : lt_kna1[], lt_kna1, dynpfields[], dynpfields.
  SELECT kna1~kunnr name1
    FROM kna1 JOIN knvv ON kna1~kunnr = knvv~kunnr
    INTO CORRESPONDING FIELDS OF TABLE lt_kna1
    WHERE vkorg = zfmstper-bukrs
      AND vkbur = zfmstper-vkbur
      AND kna1~kunnr IN lr_kunnr.

  ASSIGN lt_kna1[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'KUNNR' 'ZFMSTPER-KUNNR'
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      PERFORM f_alpha_conversion USING ls_return-fieldval
                                 CHANGING lv_kunnr.
      READ TABLE lt_kna1 INTO ls_kna1 WITH KEY kunnr = lv_kunnr.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFMSTPER-KUNNR' ls_kna1-kunnr ''.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFEXPENSE-KUNNR_NAME1'
                                  ls_kna1-name1 ''.
      ENDIF.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALUE_KUNNR  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_KOSTL  INPUT
*&---------------------------------------------------------------------*
MODULE value_kostl INPUT.
  TYPES : BEGIN OF ty_csks,
            kostl   TYPE cskt-kostl,
            ktext   TYPE cskt-ktext,
          END OF ty_csks.

  DATA : lt_csks    TYPE STANDARD TABLE OF ty_csks INITIAL SIZE 0,
         ls_csks    LIKE LINE OF lt_csks,
         lv_kostl   TYPE csks-kostl.

  CLEAR : lt_csks[], lt_csks, dynpfields[], dynpfields.
  SELECT csks~kostl ktext
    FROM csks JOIN cskt  ON csks~kokrs = cskt~kokrs
                        AND csks~kostl = cskt~kostl
    INTO CORRESPONDING FIELDS OF TABLE lt_csks
    WHERE bukrs = zfmstper-bukrs
      AND gsber = zfmstper-gsber
      AND csks~datbi >= sy-datum
      AND datab <= sy-datum.

  ASSIGN lt_csks[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'KOSTL' 'ZFMSTPER-KOSTL'
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      PERFORM f_alpha_conversion USING ls_return-fieldval
                                 CHANGING lv_kostl.
      READ TABLE lt_csks INTO ls_csks WITH KEY kostl = lv_kostl.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFMSTPER-KOSTL' ls_csks-kostl ''.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'GS_MSTP-KTEXT' ls_csks-ktext ''.

        PERFORM f_read_master_kendaraan USING lt_kend-zidke 'X'.

*        PERFORM f_modify_screen USING : 'SFR' '' '0' ''.

      ENDIF.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALUE_KOSTL  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_WWPFN  INPUT
*&---------------------------------------------------------------------*
MODULE value_wwpfn INPUT.
  TYPES : BEGIN OF ty_t25a7,
            wwpfn   TYPE t25a7-wwpfn,
            bezek   TYPE t25a7-bezek,
          END OF ty_t25a7.

  DATA : lt_t25a7    TYPE STANDARD TABLE OF ty_t25a7 INITIAL SIZE 0,
         ls_t25a7    LIKE LINE OF lt_t25a7,
         lv_wwpfn    TYPE t25a7-wwpfn.

  CLEAR : lt_t25a7[], lt_t25a7, dynpfields[], dynpfields.
  SELECT wwpfn bezek
    FROM t25a7
    INTO CORRESPONDING FIELDS OF TABLE lt_t25a7.

  ASSIGN lt_t25a7[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'WWPFN' 'ZFMSTPER-WWPFN'
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      lv_wwpfn  = ls_return-fieldval.
      READ TABLE lt_t25a7 INTO ls_t25a7 WITH KEY wwpfn = lv_wwpfn.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFMSTPER-WWPFN' ls_t25a7-wwpfn ''.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'GS_MSTP-BEZEKPFN' ls_t25a7-bezek ''.
      ENDIF.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALUE_WWPFN  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE-WWSFR  INPUT
*&---------------------------------------------------------------------*
MODULE value-wwsfr INPUT.
  TYPES : BEGIN OF ty_t25a5,
            wwsfr   TYPE t25a5-wwsfr,
            bezek   TYPE t25a5-bezek,
          END OF ty_t25a5.

  DATA : lt_t25a5    TYPE STANDARD TABLE OF ty_t25a5 INITIAL SIZE 0,
         ls_t25a5    LIKE LINE OF lt_t25a5,
         lv_wwsfr    TYPE t25a5-wwsfr.

  CLEAR : lt_t25a5[], lt_t25a5, dynpfields[], dynpfields.
  SELECT wwsfr bezek
    FROM t25a5
    INTO CORRESPONDING FIELDS OF TABLE lt_t25a5.

  ASSIGN lt_t25a5[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'WWSFR' 'ZFMSTPER-WWSFR'
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      lv_wwsfr  = ls_return-fieldval.
      READ TABLE lt_t25a5 INTO ls_t25a5 WITH KEY wwsfr = lv_wwsfr.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFMSTPER-WWSFR' ls_t25a5-wwsfr ''.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'GS_MSTP-BEZEKSFR' ls_t25a5-bezek ''.
      ENDIF.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALUE-WWSFR  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE-WWPOS  INPUT
*&---------------------------------------------------------------------*
MODULE value-wwpos INPUT.
  TYPES : BEGIN OF ty_t25a8,
            wwpos   TYPE t25a8-wwpos,
            bezek   TYPE t25a8-bezek,
          END OF ty_t25a8.

  DATA : lt_t25a8    TYPE STANDARD TABLE OF ty_t25a8,
         ls_t25a8    LIKE LINE OF lt_t25a8,
         lv_wwpos    TYPE t25a8-wwpos.

  CLEAR : lt_t25a8[], lt_t25a8, dynpfields[], dynpfields.
  SELECT wwpos bezek
    FROM t25a8
    INTO CORRESPONDING FIELDS OF TABLE lt_t25a8.

  ASSIGN lt_t25a8[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'WWPOS' 'ZFMSTPER-WWPOS'
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      lv_wwpos  = ls_return-fieldval.
      READ TABLE lt_t25a8 INTO ls_t25a8 WITH KEY wwpos = lv_wwpos.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFMSTPER-WWPOS' ls_t25a8-wwpos ''.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'GS_MSTP-BEZEKPOS' ls_t25a8-bezek ''.
      ENDIF.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALUE-WWPOS  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE-ANLN1  INPUT
*&---------------------------------------------------------------------*
MODULE value-anln1 INPUT.
  TYPES : BEGIN OF ty_anlz,
            bukrs   TYPE anlz-bukrs,
            anln1   TYPE anlz-anln1,
            anln2   TYPE anlz-anln2,
            txt50   TYPE anla-txt50,
          END OF ty_anlz.

  DATA : lt_anlz1    TYPE STANDARD TABLE OF ty_anlz INITIAL SIZE 0,
         ls_anlz     LIKE LINE OF gt_anlz,
         ls_anla     LIKE LINE OF gt_anla,
         ls_anlc     LIKE LINE OF gt_anlc,
         ls_anlz1    LIKE LINE OF lt_anlz1,
         ls_asset    LIKE LINE OF gt_asset,
         lv_anln1    TYPE anlz-anln1,
         lv_anln2    TYPE anlz-anln2,
         lv_zujhr    TYPE anla-zujhr,
         lv_answl    TYPE anlc-answl.

  CLEAR : lt_anlz1[], lt_anlz1, dynpfields[], dynpfields.
  LOOP AT gt_anlz INTO ls_anlz.
    LOOP AT gt_anla INTO ls_anla WHERE bukrs = ls_anlz-bukrs
                                   AND anln1 = ls_anlz-anln1
                                   AND anln2 = ls_anlz-anln2.
      ls_anlz1-bukrs   = ls_anlz-bukrs.
      ls_anlz1-anln1   = ls_anlz-anln1.
      ls_anlz1-anln2   = ls_anlz-anln2.
      ls_anlz1-txt50   = ls_anla-txt50.
      READ TABLE gt_asset INTO ls_asset WITH KEY bukrs = ls_anlz-bukrs
                                                 anln1 = ls_anlz-anln1
                                                 anln2 = ls_anlz-anln2.
      IF sy-subrc = 0.
        CONTINUE.
      ELSE.
        APPEND ls_anlz1 TO lt_anlz1.
      ENDIF.
      CLEAR ls_anlz1.
    ENDLOOP.
  ENDLOOP.

  SORT lt_anlz1 BY bukrs anln1 anln2.
  ASSIGN lt_anlz1[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'ANLN1' 'ZFMSTKEN-ANLN1'
                          CHANGING lv_subrc.
  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      PERFORM f_alpha_conversion USING ls_return-fieldval
                                 CHANGING lv_anln1.

      READ TABLE lt_anlz1 INTO ls_anlz1 WITH KEY anln1 = lv_anln1.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFMSTKEN-ANLN1' ls_anlz1-anln1 ''.
      ENDIF.

      PERFORM f_dynp_value_read USING 'ZFMSTKEN-ANLN2'
                                CHANGING lv_anln2.

      IF lv_anln2 IS NOT INITIAL.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFMSTKEN-TXT50' ls_anlz1-txt50 ''.

        CLEAR : lv_zujhr, lv_answl.
        READ TABLE gt_anla INTO ls_anla WITH KEY anln1 = lv_anln1
                                                 anln2 = lv_anln2.
        IF sy-subrc = 0.
          lv_zujhr  = ls_anla-zujhr.
          READ TABLE gt_anlc INTO ls_anlc WITH KEY anln1 = lv_anln1
                                                   anln2 = lv_anln2
                                                   gjahr = lv_zujhr.
          IF sy-subrc = 0.
            lv_answl  = ls_anlc-answl.
          ENDIF.
        ELSE.
          CLEAR : lv_zujhr, lv_answl.
        ENDIF.

        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFMSTKEN-ZUJHR' lv_zujhr ''.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFMSTKEN-ANSWL' lv_answl
                                  t093b-waers.
      ENDIF.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALUE-ANLN1  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE-ANLN2  INPUT
*&---------------------------------------------------------------------*
MODULE value-anln2 INPUT.
  TYPES : BEGIN OF ty_anlz2,
            bukrs   TYPE anlz-bukrs,
            anln1   TYPE anlz-anln1,
            anln2   TYPE anlz-anln2,
            txt50   TYPE anla-txt50,
          END OF ty_anlz2.

  DATA : lt_anlz2  TYPE STANDARD TABLE OF ty_anlz2 INITIAL SIZE 0,
         ls_anlz2  LIKE LINE OF lt_anlz2.

  PERFORM f_dynp_value_read USING 'ZFMSTKEN-ANLN1'
                            CHANGING lv_anln1.

  CLEAR : lt_anlz2[], lt_anlz2, dynpfields[], dynpfields,
          ls_anlz, ls_anla, ls_anlc.

  LOOP AT gt_anlz INTO ls_anlz WHERE bukrs = zfmstken-bukrs
                                 AND anln1 = lv_anln1.
    LOOP AT gt_anla INTO ls_anla WHERE bukrs = ls_anlz-bukrs
                                   AND anln1 = ls_anlz-anln1
                                   AND anln2 = ls_anlz-anln2.
      ls_anlz2-bukrs   = ls_anlz-bukrs.
      ls_anlz2-anln1   = ls_anlz-anln1.
      ls_anlz2-anln2   = ls_anlz-anln2.
      ls_anlz2-txt50   = ls_anla-txt50.
      READ TABLE gt_asset INTO ls_asset WITH KEY bukrs = ls_anlz-bukrs
                                                 anln1 = ls_anlz-anln1
                                                 anln2 = ls_anlz-anln2.
      IF sy-subrc = 0.
        CONTINUE.
      ELSE.
        APPEND ls_anlz2 TO lt_anlz2.
      ENDIF.
      CLEAR ls_anlz1.
    ENDLOOP.
  ENDLOOP.

  SORT lt_anlz2 BY bukrs anln1 anln2.
  ASSIGN lt_anlz2[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'ANLN2' 'ZFMSTKEN-ANLN2'
                          CHANGING lv_subrc.
  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      PERFORM f_alpha_conversion USING ls_return-fieldval
                                 CHANGING lv_anln2.
      READ TABLE lt_anlz2 INTO ls_anlz2 WITH KEY anln1 = lv_anln1
                                                 anln2 = lv_anln2.
      IF sy-subrc = 0.
        CLEAR : ls_anlz, lv_zujhr, lv_answl.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFMSTKEN-ANLN2' ls_anlz2-anln2 ''.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFMSTKEN-TXT50' ls_anlz2-txt50 ''.
        READ TABLE gt_anlz INTO ls_anlz WITH KEY anln1 = lv_anln1
                                                 anln2 = lv_anln2.
        IF sy-subrc = 0.
          lv_zujhr  = ls_anla-zujhr.
          READ TABLE gt_anlc INTO ls_anlc WITH KEY anln1 = lv_anln1
                                                   anln2 = lv_anln2
                                                   gjahr = lv_zujhr.
          IF sy-subrc = 0.
            lv_answl  = ls_anlc-answl.
          ENDIF.
        ENDIF.

        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFMSTKEN-ZUJHR' lv_zujhr ''.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFMSTKEN-ANSWL' lv_answl
                                  t093b-waers.
      ENDIF.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALUE-ANLN2  INPUT

*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
MODULE pai INPUT.
  CASE sy-dynnr.
    WHEN '0801'.
      gs_mstk-znorangka = zfmstken-znorangka.
      gs_mstk-anln1     = zfmstken-anln1.
      gs_mstk-anln2     = zfmstken-anln2.
      gs_mstk-jnskend   = zfmstken-jnskend.
      gs_mstk-txt50     = zfmstken-txt50.
      gs_mstk-zujhr     = zfmstken-zujhr.
      gs_mstk-answl     = zfmstken-answl.
      MODIFY gt_mstk FROM gs_mstk INDEX 1 TRANSPORTING znorangka anln1 anln2
                                                       jnskend txt50 zujhr
                                                       answl.
    WHEN '0802'.
*      IF zfmstper-kostl+7(3) = '101' OR
*        zfmstper-kostl+7(3) = '109'.
*        IF zfmstper-wwsfr IS INITIAL.
*          MESSAGE s000(zab) WITH 'Sales Force harus diisi'
*                            DISPLAY LIKE 'E'.
*          gv_error  = selected.
*        ENDIF.
*      ELSEIF zfmstper-kostl+7(3) = '201'.
*        IF zfmstper-wwpos IS INITIAL.
*          MESSAGE s000(zab) WITH 'W&D Category harus diisi'
*                            DISPLAY LIKE 'E'.
*          gv_error  = selected.
*        ENDIF.
*      ENDIF.

      IF zfmstper-lifnr IS NOT INITIAL.
        SELECT SINGLE *
          FROM lfa1
          WHERE lifnr = zfmstper-lifnr
            AND ktokk = 'EMPL'.
        IF sy-subrc <> 0.
          MESSAGE s000(zab) WITH 'Harus vendor employee'
                            DISPLAY LIKE 'E'.
          gv_error  = selected.
        ENDIF.
      ENDIF.

      IF zfmstper-zidke IS NOT INITIAL.
        SELECT SINGLE *
          FROM zf63masterperson
          INTO CORRESPONDING FIELDS OF ls_mstp
          WHERE zidke = zfmstper-zidke.
        IF sy-subrc = 0.
          IF ls_mstp-bukrs = zfmstper-bukrs AND
            ls_mstp-vkbur = zfmstper-vkbur AND
            ls_mstp-bukrs = zfmstper-bukrs AND
            ls_mstp-gtype = zfmstper-gtype AND
            ls_mstp-zidno = zfmstper-zidno.
          ELSE.
            MESSAGE s000(zab) WITH 'Kendaraan sudah digunakan'
                              DISPLAY LIKE 'E'.
            gv_error  = selected.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN '0803'.
      PERFORM f_validasi_data USING 'TYPE' '' '' '' '' '' ''.
      PERFORM f_validasi_data USING 'NOPOL' '' '' '' '' '' ''.
      PERFORM f_validasi_data USING 'NMVCH' '' '' '' '' '' ''.
*      PERFORM f_validasi_data USING 'ZIDNO'.

      gs_ship-zidno     = zfexpense-zidno.
      gs_ship-znopol    = zfexpense-znopol.
      gs_ship-bldat     = zfexpense-bldat.
      gs_ship-budat     = zfexpense-budat.
      gs_ship-xblnr     = zfexpense-xblnr.
      gs_ship-bktxt     = zfexpense-bktxt.
      gs_ship-waers     = zfexpense-waers.
      gs_ship-hkont     = zfexpense-hkont.
      gs_ship-wrbtr     = zfexpense-wrbtr.
      gs_ship-type      = zfexpense-type.
      gs_ship-nmvch     = zfexpense-nmvch.

      IF gs_ship-lfa1 IS INITIAL.
        SELECT SINGLE name1
          FROM zf63masterperson
          INTO gs_ship-name1
          WHERE bukrs = zfexpense-bukrs
            AND gsber = zfexpense-gsber
            AND vkbur = zfexpense-vkbur
            AND gtype = zfexpense-gtype
            AND zidno = zfexpense-zidno.
      ELSE.
        SELECT SINGLE name1
          FROM lfa1
          INTO gs_ship-name1
          WHERE lifnr = zfexpense-zidno.
      ENDIF.

      MODIFY gt_ship FROM gs_ship INDEX 1 TRANSPORTING zidno name1 znopol
                                                       bldat budat xblnr
                                                       bktxt waers hkont
                                                       wrbtr type nmvch.

    WHEN '0804'.
      PERFORM f_validasi_data USING 'TYPE' '' '' '' '' '' ''.

    WHEN '0811'.
      PERFORM f_validasi_data USING 'OBLIGATORY'
                                    zftransaction-kmstr
                                    zftransaction-kmend
                                    zftransaction-menge
                                    zftransaction-type
                                    zftransaction-wrbtr
                                    zftransaction-description.

      PERFORM f_validasi_data USING 'KM' zftransaction-kmstr zftransaction-kmend
                                    '' '' '' ''.

    WHEN '0812'.
      LOOP AT gt_xshp INTO ls_xshp WHERE znopol = zfexpense-znopol.
        READ TABLE gt_yshp INTO ls_yshp WITH KEY tknum = ls_xshp-tknum.
        IF sy-subrc <> 0.
          DELETE gt_xshp WHERE tknum = ls_xshp-tknum.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDMODULE.                 " PAI  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_ZIDNO  INPUT
*&---------------------------------------------------------------------*
MODULE value_zidno INPUT.
  TYPES : BEGIN OF ty_person,
            zidno    TYPE zf63masterperson-zidno,
            name1    TYPE zf63masterperson-name1,
          END OF ty_person.

  DATA : lt_zf63mp  TYPE STANDARD TABLE OF zf63masterperson INITIAL SIZE 0,
         ls_zf63mp  LIKE LINE OF lt_zf63mp.
  DATA : lv_zidno   TYPE zf63masterperson-zidno,
         lt_person  TYPE STANDARD TABLE OF ty_person INITIAL SIZE 0,
         ls_person  LIKE LINE OF lt_person.

  DATA : lv_bktxt   TYPE bkpf-bktxt.

  CLEAR : lt_zf63mp[], lt_zf63mp,
          lt_person[], lt_person,
          dynpfields[], dynpfields,
          lv_lifnr,
          lv_bktxt.

  IF gs_ship-lfa1 IS NOT INITIAL.
    SELECT zidno name1 zidke lifnr
      FROM zf63masterperson
      INTO CORRESPONDING FIELDS OF TABLE lt_zf63mp
        WHERE bukrs = zfexpense-bukrs
          AND vkbur = zfexpense-vkbur
          AND gsber = zfexpense-gsber
          AND lifnr <> space.

    LOOP AT lt_zf63mp INTO ls_zf63mp.
      ls_person-zidno   = ls_zf63mp-lifnr.
      ls_person-name1   = ls_zf63mp-name1.
      APPEND ls_person TO lt_person.
      CLEAR ls_person.
    ENDLOOP.
  ELSE.
    SELECT zidno name1 zidke lifnr
      FROM zf63masterperson
      INTO CORRESPONDING FIELDS OF TABLE lt_zf63mp
        WHERE bukrs = zfexpense-bukrs
          AND vkbur = zfexpense-vkbur
          AND gsber = zfexpense-gsber.

    LOOP AT lt_zf63mp INTO ls_zf63mp.
      ls_person-zidno   = ls_zf63mp-zidno.
      ls_person-name1   = ls_zf63mp-name1.
      APPEND ls_person TO lt_person.
      CLEAR ls_person.
    ENDLOOP.
  ENDIF.

  ASSIGN lt_person[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'ZIDNO' 'ZFEXPENSE-ZIDNO'
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      lv_zidno  = ls_return-fieldval.
      CLEAR ls_zf63mp.
      IF gs_ship-lfa1 IS NOT INITIAL.
        READ TABLE lt_zf63mp INTO ls_zf63mp WITH KEY lifnr = lv_zidno.
        IF sy-subrc = 0.
          lv_lifnr  = ls_zf63mp-lifnr.
        ENDIF.
      ELSE.
        READ TABLE lt_zf63mp INTO ls_zf63mp WITH KEY zidno = lv_zidno.
        IF sy-subrc = 0.
          lv_lifnr  = ls_zf63mp-zidno.
        ENDIF.
      ENDIF.

      PERFORM f_dynpfield TABLES dynpfields
                          USING 'ZFEXPENSE-ZIDNO' lv_lifnr ''.
      PERFORM f_dynpfield TABLES dynpfields
                          USING 'ZFEXPENSE-NAME1' ls_zf63mp-name1 ''.

      IF gs_gtype-advance IS NOT INITIAL.
        CONCATENATE gs_ship-description ls_zf63mp-name1
        INTO lv_bktxt
        SEPARATED BY space.
        gv_xbkt  = 'X'.
        PERFORM f_modify_screen USING : 'BKT' '' '0' '' ''.
      ENDIF.

      SELECT SINGLE znopol
        FROM zf63masterkend
        INTO lv_znopol
        WHERE bukrs = zfexpense-bukrs
          AND vkbur = zfexpense-vkbur
          AND gsber = zfexpense-gsber
          AND zidke = ls_zf63mp-zidke
          AND loevm = space.

      PERFORM f_dynpfield TABLES dynpfields
                          USING 'ZFEXPENSE-ZNOPOL' lv_znopol ''.
      PERFORM f_dynpfield TABLES dynpfields
                          USING 'ZFEXPENSE-BKTXT' lv_bktxt ''.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALUE_ZIDNO  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_ZNOPOL  INPUT
*&---------------------------------------------------------------------*
MODULE value_znopol INPUT.
  TYPES : BEGIN OF ty_plat,
            znopol   TYPE zf63plat-znopol,
          END OF ty_plat.

  DATA : lt_plat  TYPE STANDARD TABLE OF ty_plat INITIAL SIZE 0,
         ls_plat  LIKE LINE OF lt_plat.

  CLEAR : lt_plat[], lt_plat, dynpfields[], dynpfields.
  SELECT znopol
    FROM zf63plat
    INTO CORRESPONDING FIELDS OF TABLE lt_plat
    WHERE bukrs = zfexpense-bukrs
      AND vkbur = zfexpense-vkbur
      AND gsber = zfexpense-gsber.

  ASSIGN lt_plat[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'ZNOPOL' 'ZFEXPENSE-ZNOPOL'
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      lv_znopol  = ls_return-fieldval.
      READ TABLE lt_plat INTO ls_plat WITH KEY znopol = lv_znopol.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFEXPENSE-ZNOPOL' ls_plat-znopol ''.
      ENDIF.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALUE_ZNOPOL  INPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CASE sy-dynnr.
        WHEN '0801' OR '0802' OR '0803' OR '0810'.
          CALL FUNCTION 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
            EXPORTING
              textline1 = text-032
              textline2 = space
              titel     = text-030
            IMPORTING
              answer    = char.

          IF char = 'J'.
            LEAVE TO SCREEN 0.
          ENDIF.

        WHEN '0804'.
          PERFORM f_prepare_data USING '805'.
          SET SCREEN 805.

        WHEN '0805'.
          PERFORM f_prepare_data USING '804'.
          CLEAR ok_code.
          SET SCREEN 804.

*          CALL FUNCTION 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
*            EXPORTING
*              textline1 = text-032
*              textline2 = space
*              titel     = text-030
*            IMPORTING
*              answer    = char.
*
*          IF char = 'J'.
*            LEAVE TO SCREEN 0.
*          ENDIF.

        WHEN '0806'.
          CLEAR zfexpense-wrbtr.
          LEAVE TO SCREEN 0.

        WHEN '0808'.
          gv_subrc = 4.
          LEAVE TO SCREEN 0.

        WHEN '0809'.
          LEAVE TO SCREEN 0.

        WHEN '0811'.
          CLEAR gv_belnr.
          LEAVE TO SCREEN 0.

        WHEN '0813'.
          LEAVE TO SCREEN 0.
      ENDCASE.
  ENDCASE.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_HKONT  INPUT
*&---------------------------------------------------------------------*
MODULE value_hkont INPUT.
  TYPES : BEGIN OF ty_acct,
            ktext  TYPE zf63acckasexp-ktext,
          END OF ty_acct.

  DATA : lt_acct    TYPE STANDARD TABLE OF ty_acct INITIAL SIZE 0,
         ls_acct    LIKE LINE OF lt_acct,
         ls_zf63acc LIKE LINE OF gt_zf63acc,
         lv_hkont   TYPE skat-saknr.

  CLEAR : lt_acct[], lt_acct,
          dynpfields[], dynpfields.

  IF gt_zf63acc[] IS NOT INITIAL.
    LOOP AT gt_zf63acc INTO ls_zf63acc.
      ls_acct-ktext = ls_zf63acc-ktext.
      APPEND ls_acct TO lt_acct.
    ENDLOOP.
  ENDIF.

  ASSIGN lt_acct[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'SAKNR' 'ZFEXPENSE-HKONT'
                          CHANGING lv_subrc.
*  IF lv_subrc = 0.
*    READ TABLE return_tab INTO ls_return INDEX 1.
*    IF sy-subrc = 0.
*
**      IF sy-subrc = 0.
**        PERFORM f_dynpfield TABLES dynpfields
**                            USING 'ZFEXPENSE-HKONT' ls_zf63acc-hkont ''.
**SELECT saknr txt20
**  FROM skat
**  INTO CORRESPONDING FIELDS OF TABLE lt_acct
**  FOR ALL ENTRIES IN gt_zf63acc
**        PERFORM f_dynpfield TABLES dynpfields
**                            USING 'ZFEXPENSE-TXT20' ls_acct-txt20 ''.
**      ENDIF.
**      PERFORM f_dyn_values_update.
*    ENDIF.
*  ENDIF.
ENDMODULE.                 " VALUE_HKONT  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_TKNUM  INPUT
*&---------------------------------------------------------------------*
MODULE value_tknum INPUT.
  TYPES : BEGIN OF ty_vttk,
            tknum  TYPE vttk-tknum,
            route  TYPE vttk-route,
            exti1  TYPE vttk-exti1,
            datbg  TYPE vttk-datbg,
            daten  TYPE vttk-daten,
            signi  TYPE vttk-signi,
          END OF ty_vttk.

  DATA : lt_vttk    TYPE STANDARD TABLE OF ty_vttk INITIAL SIZE 0,
         ls_vttk    LIKE LINE OF lt_vttk,
         lv_tknum   TYPE vttk-tknum,
         lt_trnshp  TYPE STANDARD TABLE OF zf63trnshp2,
         ls_trnshp  LIKE LINE OF lt_trnshp.

  CLEAR : lt_vttk[], lt_vttk, dynpfields[], dynpfields, lv_tknum.

  CASE sy-dynnr.
    WHEN '0812'.
      lv_znopol = zfexpense-znopol.
    WHEN OTHERS.
      PERFORM f_dynp_value_read USING 'ZFEXPENSE-ZNOPOL'
                                CHANGING lv_znopol.
  ENDCASE.

  SELECT tknum route exti1 datbg daten signi
    FROM vttk
    INTO CORRESPONDING FIELDS OF TABLE lt_vttk
    WHERE tplst = pa_gsber
      AND signi = lv_znopol.

  IF lt_vttk[] IS NOT INITIAL.
    SELECT *
      FROM zf63trnshp2
      INTO CORRESPONDING FIELDS OF TABLE lt_trnshp
      FOR ALL ENTRIES IN lt_vttk
      WHERE tknum = lt_vttk-tknum.

    SORT lt_vttk BY tknum.
    SORT lt_trnshp BY tknum.
    LOOP AT lt_vttk INTO ls_vttk.
      READ TABLE lt_trnshp INTO ls_trnshp
                           WITH KEY tknum = ls_vttk-tknum
                           BINARY SEARCH.
      IF sy-subrc = 0.
        DELETE TABLE lt_vttk FROM ls_vttk.
      ENDIF.
    ENDLOOP.
  ENDIF.

  ASSIGN lt_vttk[] TO <fs_tab>.

  CLEAR lv_subrc.
  CASE sy-dynnr.
    WHEN '0812'.
      PERFORM f_value_request TABLES return_tab
                              USING 'TKNUM' 'ZFSHIPMENT-TKNUM'
                              CHANGING lv_subrc.
    WHEN OTHERS.
      PERFORM f_value_request TABLES return_tab
                              USING 'TKNUM' 'ZFEXPENSE-TKNUM'
                              CHANGING lv_subrc.
  ENDCASE.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      PERFORM f_alpha_conversion USING ls_return-fieldval
                                 CHANGING lv_tknum.

      READ TABLE lt_vttk INTO ls_vttk WITH KEY tknum = lv_tknum.
      IF sy-subrc = 0.
        CASE sy-dynnr.
          WHEN '0812'.
            PERFORM f_dynpfield TABLES dynpfields
                                USING 'ZFSHIPMENT-TKNUM' ls_vttk-tknum ''.
          WHEN OTHERS.
            PERFORM f_dynpfield TABLES dynpfields
                                USING 'ZFEXPENSE-TKNUM' ls_vttk-tknum ''.
        ENDCASE.
      ENDIF.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALUE_TKNUM  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_ZIDNO_LOW  INPUT
*&---------------------------------------------------------------------*
MODULE value_zidno_low INPUT.
  CLEAR : lt_zf63mp[], lt_zf63mp,
          lt_person[], lt_person,
          dynpfields[], dynpfields,
          lv_lifnr.

  IF gs_ship-lfa1 IS NOT INITIAL.
    SELECT zidno name1 zidke lifnr
      FROM zf63masterperson
      INTO CORRESPONDING FIELDS OF TABLE lt_zf63mp
        WHERE bukrs = zfexpense-bukrs
          AND vkbur = zfexpense-vkbur
          AND gsber = zfexpense-gsber
          AND lifnr <> space.

    LOOP AT lt_zf63mp INTO ls_zf63mp.
      ls_person-zidno   = ls_zf63mp-lifnr.
      ls_person-name1   = ls_zf63mp-name1.
      APPEND ls_person TO lt_person.
      CLEAR ls_person.
    ENDLOOP.
  ELSE.
    SELECT zidno name1 zidke lifnr
      FROM zf63masterperson
      INTO CORRESPONDING FIELDS OF TABLE lt_zf63mp
        WHERE bukrs = zfexpense-bukrs
          AND vkbur = zfexpense-vkbur
          AND gsber = zfexpense-gsber.

    LOOP AT lt_zf63mp INTO ls_zf63mp.
      ls_person-zidno   = ls_zf63mp-zidno.
      ls_person-name1   = ls_zf63mp-name1.
      APPEND ls_person TO lt_person.
      CLEAR ls_person.
    ENDLOOP.
  ENDIF.

  ASSIGN lt_person[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'ZIDNO' 'ZFEXPENSE-ZIDNO_LOW'
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      lv_zidno  = ls_return-fieldval.
      CLEAR ls_zf63mp.
      IF gs_ship-lfa1 IS NOT INITIAL.
        READ TABLE lt_zf63mp INTO ls_zf63mp WITH KEY lifnr = lv_zidno.
        IF sy-subrc = 0.
          lv_lifnr  = ls_zf63mp-lifnr.
        ENDIF.
      ELSE.
        READ TABLE lt_zf63mp INTO ls_zf63mp WITH KEY zidno = lv_zidno.
        IF sy-subrc = 0.
          lv_lifnr  = ls_zf63mp-zidno.
        ENDIF.
      ENDIF.

      PERFORM f_dynpfield TABLES dynpfields
                          USING 'ZFEXPENSE-ZIDNO_LOW' lv_lifnr ''.
      PERFORM f_dynpfield TABLES dynpfields
                          USING 'ZFEXPENSE-NAME1' ls_zf63mp-name1 ''.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALUE_ZIDNO_LOW  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_ZIDNO_HIGH  INPUT
*&---------------------------------------------------------------------*
MODULE value_zidno_high INPUT.
  CLEAR : lt_zf63mp[], lt_zf63mp,
          lt_person[], lt_person,
          dynpfields[], dynpfields,
          lv_lifnr.

  IF gs_ship-lfa1 IS NOT INITIAL.
    SELECT zidno name1 zidke lifnr
      FROM zf63masterperson
      INTO CORRESPONDING FIELDS OF TABLE lt_zf63mp
        WHERE bukrs = zfexpense-bukrs
          AND vkbur = zfexpense-vkbur
          AND gsber = zfexpense-gsber
          AND lifnr <> space.

    LOOP AT lt_zf63mp INTO ls_zf63mp.
      ls_person-zidno   = ls_zf63mp-lifnr.
      ls_person-name1   = ls_zf63mp-name1.
      APPEND ls_person TO lt_person.
      CLEAR ls_person.
    ENDLOOP.
  ELSE.
    SELECT zidno name1 zidke lifnr
      FROM zf63masterperson
      INTO CORRESPONDING FIELDS OF TABLE lt_zf63mp
        WHERE bukrs = zfexpense-bukrs
          AND vkbur = zfexpense-vkbur
          AND gsber = zfexpense-gsber.

    LOOP AT lt_zf63mp INTO ls_zf63mp.
      ls_person-zidno   = ls_zf63mp-zidno.
      ls_person-name1   = ls_zf63mp-name1.
      APPEND ls_person TO lt_person.
      CLEAR ls_person.
    ENDLOOP.
  ENDIF.

  ASSIGN lt_person[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'ZIDNO' 'ZFEXPENSE-ZIDNO_HIGH'
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      lv_zidno  = ls_return-fieldval.
      CLEAR ls_zf63mp.
      IF gs_ship-lfa1 IS NOT INITIAL.
        READ TABLE lt_zf63mp INTO ls_zf63mp WITH KEY lifnr = lv_zidno.
        IF sy-subrc = 0.
          lv_lifnr  = ls_zf63mp-lifnr.
        ENDIF.
      ELSE.
        READ TABLE lt_zf63mp INTO ls_zf63mp WITH KEY zidno = lv_zidno.
        IF sy-subrc = 0.
          lv_lifnr  = ls_zf63mp-zidno.
        ENDIF.
      ENDIF.

      PERFORM f_dynpfield TABLES dynpfields
                          USING 'ZFEXPENSE-ZIDNO_HIGH' lv_lifnr ''.
      PERFORM f_dynpfield TABLES dynpfields
                          USING 'ZFEXPENSE-NAME1' ls_zf63mp-name1 ''.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALUE_ZIDNO_HIGH  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_PRINT
*&---------------------------------------------------------------------*
FORM f_print .

ENDFORM.                    " F_PRINT

*&---------------------------------------------------------------------*
*&      Module  VALUE_VBUND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE value_vbund INPUT.
  DATA : lv_vbund   TYPE zfgskunnr-vbund,
         ls_trpar   LIKE LINE OF gt_trpar.

  CLEAR : dynpfields[], dynpfields.

  ASSIGN gt_trpar[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'VBUND' 'ZFEXPENSE-VBUND'
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      PERFORM f_alpha_conversion USING ls_return-fieldval
                                 CHANGING lv_vbund.

      READ TABLE gt_trpar INTO ls_trpar WITH KEY vbund = lv_vbund.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFEXPENSE-VBUND' ls_trpar-vbund ''.
      ENDIF.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALUE_VBUND  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_NMVCH  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE value_nmvch INPUT.
  DATA : lt_voucher TYPE STANDARD TABLE OF ty_voucher,
         ls_voucher LIKE LINE OF lt_voucher,
         lv_nmvch   TYPE zfexpense-nmvch.

  lt_voucher[]  = gt_voucher[].

  SORT lt_voucher BY nmvch.
  DELETE ADJACENT DUPLICATES FROM lt_voucher COMPARING nmvch.

  ASSIGN lt_voucher[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'NMVCH' 'ZFEXPENSE-NMVCH'
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      PERFORM f_alpha_conversion USING ls_return-fieldval
                                 CHANGING lv_nmvch.

      READ TABLE lt_voucher INTO ls_voucher
                            WITH KEY nmvch = lv_nmvch.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFEXPENSE-NMVCH'
                                  ls_voucher-nmvch ''.
      ENDIF.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALUE_NMVCH  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_TRANS  INPUT
*&---------------------------------------------------------------------*
MODULE value_trans INPUT.
  DATA : lt_ltext       TYPE STANDARD TABLE OF ty_ltext,
         ls_ltext       LIKE LINE OF lt_ltext,
         lv_ltext       TYPE zf63tytpeexpdesc-ltext,
         lv_char1       TYPE string,
         lv_char2       TYPE string.

  SPLIT gs_mstk-jnskend AT space INTO lv_char1 lv_char2.

  CLEAR : ls_tyexpdtl, lt_ltext[], lt_ltext, ls_ltext,
          dynpfields[], dynpfields.
  LOOP AT gt_tyexpdtl INTO ls_tyexpdtl.
    ls_ltext-type   = ls_tyexpdtl-type.
    SEARCH ls_tyexpdtl-description FOR 'BENSIN'.
    IF sy-subrc = 0.
      IF lv_char2 <> 'BENSIN'.
        CONTINUE.
      ENDIF.
    ENDIF.

    SEARCH ls_tyexpdtl-description FOR 'SOLAR'.
    IF sy-subrc = 0.
      IF lv_char2 <> 'SOLAR'.
        CONTINUE.
      ENDIF.
    ENDIF.

    ls_ltext-ltext  = ls_tyexpdtl-ltext.
    APPEND ls_ltext TO lt_ltext.
    CLEAR ls_ltext.
  ENDLOOP.

  ASSIGN lt_ltext[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'LTEXT' 'ZFTRANSACTION-LTEXT'
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      PERFORM f_alpha_conversion USING ls_return-fieldval
                                 CHANGING lv_ltext.

      READ TABLE lt_ltext INTO ls_ltext
                          WITH KEY ltext = lv_ltext.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFTRANSACTION-LTEXT'
                                  ls_ltext-ltext ''.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFTRANSACTION-TYPE'
                                  ls_ltext-type ''.
      ENDIF.
      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALUE_TRANS  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_DEPARTEMEN  INPUT
*&---------------------------------------------------------------------*
MODULE value_departemen INPUT.
  DATA : lt_proseq1     TYPE STANDARD TABLE OF ty_proseq,
         ls_proseq1     LIKE LINE OF lt_proseq1,
         ls_proseq2     LIKE LINE OF gt_proseq,
         lv_departemen  TYPE zf63proseqctrl-departemen.

  CLEAR : ls_tyexpdtl, lt_proseq1[], lt_proseq1, dynpfields[], dynpfields.
  LOOP AT gt_proseq INTO ls_proseq.
    ls_proseq1-departemen  = ls_proseq-departemen.
    APPEND ls_proseq1 TO lt_proseq1.
    CLEAR ls_proseq1.
  ENDLOOP.

  ASSIGN lt_proseq1[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'DEPARTEMEN' 'ZFTRANSACTION-DEPARTEMEN'
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      PERFORM f_alpha_conversion USING ls_return-fieldval
                                 CHANGING lv_departemen.

      READ TABLE lt_proseq1 INTO ls_proseq1
                            WITH KEY departemen = lv_departemen.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'ZFTRANSACTION-DEPARTEMEN'
                                  ls_proseq1-departemen ''.
      ENDIF.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALUE_DEPARTEMEN  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_KTEXT  INPUT
*&---------------------------------------------------------------------*
MODULE value_ktext INPUT.
  DATA : lt_payment   TYPE STANDARD TABLE OF ty_payment,
         ls_payment   LIKE LINE OF lt_payment.

  CLEAR : ls_zf63acc, dynpfields[], dynpfields.

  LOOP AT gt_zf63acc INTO ls_zf63acc.
    ls_payment-hkont  = ls_zf63acc-hkont.
    ls_payment-ktext  = ls_zf63acc-ktext.
    APPEND ls_payment TO lt_payment.
    CLEAR ls_payment.
  ENDLOOP.

  ASSIGN lt_payment[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'KTEXT' 'GV_KTEXT'
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      READ TABLE lt_payment INTO ls_payment WITH KEY ktext = ls_return-fieldval.
      IF sy-subrc = 0.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'GV_KTEXT' ls_payment-ktext ''.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'GV_PAYHKONT' ls_payment-hkont ''.
      ENDIF.

      PERFORM f_dyn_values_update.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALUE_KTEXT  INPUT
