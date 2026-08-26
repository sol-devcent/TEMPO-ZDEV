FUNCTION Z_GDTXFC_FORMAT_TO_ESPT1_V001.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(FI_VAT_TYPE) TYPE  CHAR01
*"     REFERENCE(FI_ZGDTXST0012) LIKE  ZGDTXST0012 STRUCTURE
*"        ZGDTXST0012 OPTIONAL
*"     REFERENCE(FI_ZGDTXST0013) LIKE  ZGDTXST0013 STRUCTURE
*"        ZGDTXST0013 OPTIONAL
*"  EXPORTING
*"     REFERENCE(FE_ESPT) LIKE  ZGDTXST0014 STRUCTURE  ZGDTXST0014
*"  EXCEPTIONS
*"      KODELAMP_MUST_BE_FILLED
*"      KODESTAT_MUST_BE_FILLED
*"      KODEDOK_MUST_BE_FILLED
*"      NPWP_IS_BLANK
*"      NPWP_NAME_IS_BLANK
*"      VAT_OUT_STRUCT_MUST_BE_FILLED
*"      VAT_IN_STRUCT_MUST_BE_FILLED
*"----------------------------------------------------------------------
  DATA ld_actype LIKE zgdtxdt0015-actype.
  DATA ld_itamt LIKE zgdtxst0012-itamt.
  DATA ld_fakppn LIKE zgdtxst0012-fakppn.
  DATA ld_ppnbm LIKE zgdtxst0012-ppnbm.
  DATA ld_totfj LIKE zgdtxst0013-totfj.
  DATA ld_totfj1 LIKE zgdtxst0013-totfj.
  DATA ld_ppnbmlast LIKE zgdtxst0013-ppnbmlast.

  CASE fi_vat_type.
* ---------- VAT In
    WHEN 'I'.    "VAT-In
      IF fi_zgdtxst0012 IS INITIAL.
        MESSAGE e000(zab) RAISING vat_out_struct_must_be_filled.
      ENDIF.

*-----Column 1
      fe_espt-kodepajak = 'B'.

      SELECT SINGLE actype
                    INTO ld_actype
                    FROM zgdtxdt0015
                    WHERE brnch = fi_zgdtxst0012-brnch AND
                          hkontfr LE fi_zgdtxst0012-hkont AND
                          hkontto GE fi_zgdtxst0012-hkont.

*-----Column 2 & 4
      CASE fi_zgdtxst0012-form.
        WHEN 'B1'.
          fe_espt-kodelamp = '2'.
          IF fi_zgdtxst0012-masatx = fi_zgdtxst0012-fakdat+(6)
             AND ld_actype = 'I'.
            fe_espt-kodedok = '2'.
          ELSEIF fi_zgdtxst0012-masatx = fi_zgdtxst0012-fakdat+(6)
              AND ld_actype = 'L'.
            fe_espt-kodedok = '1'.
          ENDIF.
        WHEN 'B2'.
          fe_espt-kodelamp = '2'.
        WHEN 'B4'.
          fe_espt-kodelamp = '3'.
      ENDCASE.

*-----Column 3
      CASE fi_zgdtxst0012-fakturno1(2).
        WHEN '01'.
          fe_espt-kodestat = '1'.
        WHEN '02'.
          fe_espt-kodestat = '2'.
        WHEN '03'.
          fe_espt-kodestat = '3'.
        WHEN '04'.
          fe_espt-kodestat = '4'.
        WHEN '05'.
          fe_espt-kodestat = '5'.
        WHEN '06'.
          fe_espt-kodestat = '6'.
        WHEN '07'.
          fe_espt-kodestat = '7'.
        WHEN '08'.
          fe_espt-kodestat = '8'.
        WHEN '09'.
          fe_espt-kodestat = '9'.
        WHEN OTHERS.
          fe_espt-kodestat = '1'.
      ENDCASE.

*-----Column 5
      IF fi_zgdtxst0012-credit = 'R'.   "nota retur
        fe_espt-kodedok = '4'.
      ENDIF.

      IF fi_zgdtxst0012-npwp IS INITIAL.
        fe_espt-kodenpwp = '000000000000000'.
      ELSE.
        CALL FUNCTION 'ZF_NPWP_MODIFICATION'
             EXPORTING
                  npwp_in  = fi_zgdtxst0012-npwp
             IMPORTING
                  npwp_out = fe_espt-kodenpwp.
      ENDIF.

*-----Column 6
      fe_espt-kodenama = fi_zgdtxst0012-name.

*-----Column 7
      fe_espt-kodecabang = fi_zgdtxst0012-fakturno1+4(3).

*-----Column 8
      fe_espt-kodeseri = fi_zgdtxst0012-fakturno1+11(8).

*-----Column 9
      CONCATENATE fi_zgdtxst0012-fakdat+6(2)
                  fi_zgdtxst0012-fakdat+4(2)
                  fi_zgdtxst0012-fakdat+(4)
                  INTO fe_espt-kodetgl
                  SEPARATED BY '/'.

*-----Column 11
      fe_espt-kodemstx = fi_zgdtxst0012-masatx+4(2).

*-----Column 12
      fe_espt-kodethn = fi_zgdtxst0012-masatx+(4).

*-----Column 13
      fe_espt-koreksi = fi_zgdtxst0012-corrno.

*-----Column 14
      IF fi_zgdtxst0012-fakppn < 0.
        ld_fakppn = ( -1 ) * fi_zgdtxst0012-fakppn.
        WRITE ld_fakppn CURRENCY fi_zgdtxst0012-waers
              TO fe_espt-nilppn NO-GROUPING.
        SHIFT fe_espt-nilppn LEFT DELETING LEADING space.
        CONCATENATE '-' fe_espt-nilppn INTO fe_espt-nilppn.
      ELSE.
        ld_fakppn = fi_zgdtxst0012-fakppn.
        WRITE ld_fakppn CURRENCY fi_zgdtxst0012-waers
              TO fe_espt-nilppn NO-GROUPING.
      ENDIF.

*-----Column 15
      IF fi_zgdtxst0012-itamt < 0.
        ld_itamt = ( -1 ) * fi_zgdtxst0012-itamt.
        WRITE ld_itamt CURRENCY fi_zgdtxst0012-waers
              TO fe_espt-nilbill NO-GROUPING.
        SHIFT fe_espt-nilbill LEFT DELETING LEADING space.
        CONCATENATE '-' fe_espt-nilbill INTO fe_espt-nilbill.
      ELSE.
        ld_itamt = fi_zgdtxst0012-itamt.
        WRITE ld_itamt CURRENCY fi_zgdtxst0012-waers
              TO fe_espt-nilbill NO-GROUPING.
      ENDIF.

*-----Column 16
      IF fi_zgdtxst0012-ppnbm < 0.
        ld_ppnbm = ( -1 ) * fi_zgdtxst0012-ppnbm.
        WRITE ld_ppnbm CURRENCY fi_zgdtxst0012-waers
              TO fe_espt-nilppnbm NO-GROUPING.
        SHIFT fe_espt-nilppnbm LEFT DELETING LEADING space.
        CONCATENATE '-' fe_espt-nilppnbm INTO fe_espt-nilppnbm.
      ELSE.
        ld_ppnbm = fi_zgdtxst0012-ppnbm.
        WRITE ld_ppnbm CURRENCY fi_zgdtxst0012-waers
              TO fe_espt-nilppnbm NO-GROUPING.
      ENDIF.


* ---------- VAT Out
    WHEN 'O'.    "VAT-Out
      IF fi_zgdtxst0013 IS INITIAL.
        MESSAGE e000(zab) RAISING vat_in_struct_must_be_filled.
      ENDIF.

*-----Column 1
      fe_espt-kodepajak = 'A'.

*----- Column 2
      fe_espt-kodelamp = '2'.

*-----Column 3 & 4
      IF fe_espt-kodelamp EQ '1'.
        fe_espt-kodestat = '0'.
        fe_espt-kodedok = '0'.
      ELSE.
        fe_espt-kodestat = fi_zgdtxst0013-fakturno1+1(1).
        IF fi_zgdtxst0013-fakturno IS INITIAL.
          fe_espt-kodedok = '3'.   "FP Sederhana
        ELSEIF fi_zgdtxst0013-noretur IS INITIAL.
          fe_espt-kodedok = '1'.   "FP Standard
        ELSEIF NOT fi_zgdtxst0013-noretur IS INITIAL.
          fe_espt-kodedok = '2'.   "Nota Retur
        ENDIF.
      ENDIF.

*-----Column 5
      IF fi_zgdtxst0013-npwp IS INITIAL.
        fe_espt-kodenpwp = '000000000000000'.
      ELSE.
        CALL FUNCTION 'ZF_NPWP_MODIFICATION'
             EXPORTING
                  npwp_in  = fi_zgdtxst0013-npwp
             IMPORTING
                  npwp_out = fe_espt-kodenpwp.
      ENDIF.

*-----Column 6
      fe_espt-kodenama = fi_zgdtxst0013-name+(50).

*-----Column 7
      fe_espt-kodecabang = fi_zgdtxst0013-fakturno1+4(3).

*-----Column 8
      fe_espt-kodedigit = fi_zgdtxst0013-masatx+2(2).

*-----Column 9
      fe_espt-kodeseri = fi_zgdtxst0013-fakturno1+11(8).

*-----Column 10
      IF NOT fi_zgdtxst0013-fakdat IS INITIAL.   "STANDARD
        CONCATENATE fi_zgdtxst0013-fakdat+6(2)
                    fi_zgdtxst0013-fakdat+4(2)
                    fi_zgdtxst0013-fakdat+(4)
                    INTO fe_espt-kodetgl
                    SEPARATED BY '/'.
      ELSE.                                      "SEDERHANA
        CONCATENATE fi_zgdtxst0013-fkdat+6(2)
                    fi_zgdtxst0013-fkdat+4(2)
                    fi_zgdtxst0013-fkdat+(4)
                    INTO fe_espt-kodetgl
                    SEPARATED BY '/'.
      ENDIF.

*-----Column 11

*-----Column 12
      fe_espt-kodemstx = fi_zgdtxst0013-masatx+4(2).

*-----Column 13
      fe_espt-kodethn = fi_zgdtxst0013-masatx+(4).

*-----Column 10,12,13 for NOTA RETUR
      IF NOT fi_zgdtxst0013-noretur IS INITIAL.   "nota retur
        CONCATENATE fi_zgdtxst0013-dtretur+6(2)
                    fi_zgdtxst0013-dtretur+4(2)
                    fi_zgdtxst0013-dtretur+(4)
                    INTO fe_espt-kodetgl
                    SEPARATED BY '/'.
        fe_espt-kodemstx = fi_zgdtxst0013-dtretur+4(2).
        fe_espt-kodethn = fi_zgdtxst0013-dtretur+(4).
      ENDIF.

*-----Column 14
      fe_espt-koreksi = '0'.

*-----Column 15
      IF fi_zgdtxst0013-dpp < 0.
        ld_totfj = ( -1 ) * fi_zgdtxst0013-dpp.
      ELSE.
        ld_totfj = fi_zgdtxst0013-dpp.
      ENDIF.
      WRITE ld_totfj CURRENCY fi_zgdtxst0013-waers
            TO fe_espt-nilbill NO-GROUPING.

*-----Column 16
      IF fi_zgdtxst0013-fakppn < 0.
        ld_totfj1 = ( -1 ) * fi_zgdtxst0013-fakppn.
      ELSE.
        ld_totfj1 = fi_zgdtxst0013-fakppn.
      ENDIF.
      WRITE ld_totfj1 CURRENCY fi_zgdtxst0013-waers
            TO fe_espt-nilppn NO-GROUPING.

*-----Column 17
      IF fi_zgdtxst0013-ppnbmlast < 0.
        ld_ppnbmlast = ( -1 ) * fi_zgdtxst0013-ppnbmlast.
      ELSE.
        ld_ppnbmlast = fi_zgdtxst0013-ppnbmlast.
      ENDIF.
      WRITE ld_ppnbmlast CURRENCY fi_zgdtxst0013-waers
            TO fe_espt-nilppnbm NO-GROUPING.

  ENDCASE.

ENDFUNCTION.
