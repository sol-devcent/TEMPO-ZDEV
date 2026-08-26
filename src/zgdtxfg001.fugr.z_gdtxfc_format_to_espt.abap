FUNCTION z_gdtxfc_format_to_espt.
*"----------------------------------------------------------------------
*"*"Local interface:
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
  DATA ld_ppnbm LIKE zgdtxst0012-ppnbm.
  DATA ld_totfj LIKE zgdtxst0013-totfj.
  DATA ld_ppnbmlast LIKE zgdtxst0013-ppnbmlast.

  CASE fi_vat_type.
    WHEN 'I'.    "VAT-In
      IF fi_zgdtxst0012 IS INITIAL.
        MESSAGE e000(zab) RAISING vat_out_struct_must_be_filled.
      ENDIF.

*-----Column 1
      CASE fi_zgdtxst0012-form.
        WHEN 'B1'.
          fe_espt-kodelamp = '4'.
*---------Column 2
          SELECT SINGLE actype
                        INTO ld_actype
                        FROM zgdtxdt0015
                        WHERE brnch = fi_zgdtxst0012-brnch AND
                              hkontfr LE fi_zgdtxst0012-hkont AND
                              hkontto GE fi_zgdtxst0012-hkont.
          IF sy-subrc = 0.
*-----------Import & Masa pajak sama
            IF fi_zgdtxst0012-masatx = fi_zgdtxst0012-fakdat+(6)
               AND ld_actype = 'I'.
              fe_espt-kodestat = '1'.
*-------------Column 3
              fe_espt-kodedok = '3'.  "PIB/PIUD
*-------------Column 6
              CLEAR fe_espt-kodeprfp. "PIB/PIUD
*-------------Column 8
              fe_espt-kodenofp = fi_zgdtxst0012-fakturno. "PIB/PIUD

*-----------Local & Masa pajak sama
            ELSEIF fi_zgdtxst0012-masatx = fi_zgdtxst0012-fakdat+(6)
                AND ld_actype = 'L'.
              fe_espt-kodestat = '2'.
*-------------Column 3
              fe_espt-kodedok = '2'.
*-------------Column 6
              fe_espt-kodeprfp = fi_zgdtxst0012-fakturno+(9).
*-------------Column 8
              fe_espt-kodenofp = fi_zgdtxst0012-fakturno+10(7).

*-----------Import & Masa pajak beda
            ELSEIF fi_zgdtxst0012-masatx <> fi_zgdtxst0012-fakdat+(6)
                 AND ld_actype = 'I'.
              fe_espt-kodestat = '3'.
*-------------Column 3
              fe_espt-kodedok = '3'.  "PIB/PIUD
*-------------Column 6
              CLEAR fe_espt-kodeprfp. "PIB/PIUD
*-------------Column 8
              fe_espt-kodenofp = fi_zgdtxst0012-fakturno. "PIB/PIUD

*-----------Local & Masa pajak beda
            ELSEIF fi_zgdtxst0012-masatx <> fi_zgdtxst0012-fakdat+(6)
                AND ld_actype = 'L'.
              fe_espt-kodestat = '4'.
*-------------Column 3
              fe_espt-kodedok = '2'.
*-------------Column 6
              fe_espt-kodeprfp = fi_zgdtxst0012-fakturno+(9).
*-------------Column 8
              fe_espt-kodenofp = fi_zgdtxst0012-fakturno+10(7).

            ELSE.
              CLEAR fe_espt-kodestat.
*              MESSAGE e000(zab) RAISING kodestat_must_be_filled.
            ENDIF.
          ELSE.
            CLEAR fe_espt-kodestat.
*            MESSAGE e000(zab) RAISING kodestat_must_be_filled.
          ENDIF.
        WHEN 'B2'.
          fe_espt-kodelamp = '5'.
*---------Column 2
          CLEAR fe_espt-kodestat.
        WHEN 'B4'.
          fe_espt-kodelamp = '7'.
*---------Column 2
          IF fi_zgdtxst0012-masatx = fi_zgdtxst0012-fakdat+(6).
            fe_espt-kodestat = '1'.
          ELSE.
            fe_espt-kodestat = '2'.
          ENDIF.
      ENDCASE.

*-----Column 3 --- replace column 3 for NR
      IF fi_zgdtxst0012-credit = 'R'.   "nota retur
        fe_espt-kodedok = '5'.
      ENDIF.

*-----Column 4
      IF fi_zgdtxst0012-npwp IS INITIAL.
        fe_espt-kodenpwp = '000000000000000'.
      ELSE.
        CALL FUNCTION 'ZF_NPWP_MODIFICATION'
             EXPORTING
                  npwp_in  = fi_zgdtxst0012-npwp
             IMPORTING
                  npwp_out = fe_espt-kodenpwp.
      ENDIF.

*-----Column 5
      fe_espt-kodenama = fi_zgdtxst0012-name.

*-----Column 7
      IF fi_zgdtxst0012-credit = 'R'.   "nota retur
        fe_espt-kodenoret = fi_zgdtxst0012-belnr.
      ELSE.
        CLEAR fe_espt-kodenoret.
      ENDIF.

*-----Column 9
      CONCATENATE fi_zgdtxst0012-fakdat+6(2)
                  fi_zgdtxst0012-fakdat+4(2)
                  fi_zgdtxst0012-fakdat+(4)
                  INTO fe_espt-kodetgl
                  SEPARATED BY '/'.

*-----Column 10
      fe_espt-kodemstx = fi_zgdtxst0012-masatx+4(2).

*-----Column 11
      fe_espt-kodethn = fi_zgdtxst0012-masatx+(4).

*-----Column 12
      fe_espt-koreksi = fi_zgdtxst0012-corrno.

*-----Column 13
      fe_espt-ppntarif = '10/100'.

*-----Column 14
      IF fi_zgdtxst0012-itamt < 0.
        ld_itamt = ( -1 ) * fi_zgdtxst0012-itamt.
      ELSE.
        ld_itamt = fi_zgdtxst0012-itamt.
      ENDIF.
      WRITE ld_itamt CURRENCY fi_zgdtxst0012-waers
            TO fe_espt-nilbill NO-GROUPING.

*-----Column 15
      IF fi_zgdtxst0012-ppnbm < 0.
        ld_ppnbm = ( -1 ) * fi_zgdtxst0012-ppnbm.
      ELSE.
        ld_ppnbm = fi_zgdtxst0012-ppnbm.
      ENDIF.
      WRITE ld_ppnbm CURRENCY fi_zgdtxst0012-waers
            TO fe_espt-nilppnbm NO-GROUPING.


    WHEN 'O'.    "VAT-Out
      IF fi_zgdtxst0013 IS INITIAL.
        MESSAGE e000(zab) RAISING vat_in_struct_must_be_filled.
      ENDIF.

*-----Column 1
      CASE fi_zgdtxst0013-form.
        WHEN 'A1'.
          fe_espt-kodelamp = '1'.
*---------Column 2
          CLEAR fe_espt-kodestat.
        WHEN 'A2'.
          fe_espt-kodelamp = '2'.
*---------Column 2
          CLEAR fe_espt-kodestat.
        WHEN 'A3'.
          fe_espt-kodelamp = '3'.
*---------Column 2
          IF NOT fi_zgdtxst0013-sspdat IS INITIAL.  "SSP diterima
            fe_espt-kodestat = '1'.
          ELSE.            "SSP blm diterima
            fe_espt-kodestat = '2'.
          ENDIF.
      ENDCASE.

*-----Column 3
      IF fi_zgdtxst0013-fakturno IS INITIAL.
        fe_espt-kodedok = '1'.   "FP Sederhana
      ELSEIF fi_zgdtxst0013-noretur IS INITIAL.
        fe_espt-kodedok = '2'.   "FP Standard
      ELSEIF NOT fi_zgdtxst0013-noretur IS INITIAL.
        fe_espt-kodedok = '5'.   "Nota Retur
      ENDIF.

*-----Column 4
      IF fi_zgdtxst0013-npwp IS INITIAL.
        fe_espt-kodenpwp = '000000000000000'.
      ELSE.
        CALL FUNCTION 'ZF_NPWP_MODIFICATION'
             EXPORTING
                  npwp_in  = fi_zgdtxst0013-npwp
             IMPORTING
                  npwp_out = fe_espt-kodenpwp.
      ENDIF.

*-----Column 5
      fe_espt-kodenama = fi_zgdtxst0013-name+(50).

*-----Column 6
      fe_espt-kodeprfp = fi_zgdtxst0013-fakturno+(9).

*-----Column 7
      IF NOT fi_zgdtxst0013-noretur IS INITIAL.   "nota retur
        fe_espt-kodenoret = fi_zgdtxst0013-noretur.
      ELSE.
        CLEAR fe_espt-kodenoret.
      ENDIF.

*-----Column 8
      IF NOT fi_zgdtxst0013-fakturno IS INITIAL.   "STANDARD
        fe_espt-kodenofp = fi_zgdtxst0013-fakturno+10(7).
      ELSE.                                        "SEDERHANA
        fe_espt-kodenofp = fi_zgdtxst0013-vbeln.
      ENDIF.

*-----Column 9
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

      IF NOT fi_zgdtxst0013-noretur IS INITIAL.   "nota retur
        CONCATENATE fi_zgdtxst0013-dtretur+6(2)
                    fi_zgdtxst0013-dtretur+4(2)
                    fi_zgdtxst0013-dtretur+(4)
                    INTO fe_espt-kodetgl
                    SEPARATED BY '/'.
      ENDIF.

*-----Column 10
      fe_espt-kodemstx = fi_zgdtxst0013-masatx+4(2).

*-----Column 11
      fe_espt-kodethn = fi_zgdtxst0013-masatx+(4).

*-----Column 9,10,11 for NOTA RETUR
      IF NOT fi_zgdtxst0013-noretur IS INITIAL.   "nota retur
        CONCATENATE fi_zgdtxst0013-dtretur+6(2)
                    fi_zgdtxst0013-dtretur+4(2)
                    fi_zgdtxst0013-dtretur+(4)
                    INTO fe_espt-kodetgl
                    SEPARATED BY '/'.
        fe_espt-kodemstx = fi_zgdtxst0013-dtretur+4(2).
        fe_espt-kodethn = fi_zgdtxst0013-dtretur+(4).
      ENDIF.

*-----Column 12
      fe_espt-koreksi = '0'.

*-----Column 13
      fe_espt-ppntarif = '10/100'.

*-----Column 14
      IF fi_zgdtxst0013-totfj < 0.
        ld_totfj = ( -1 ) * fi_zgdtxst0013-totfj.
      ELSE.
        ld_totfj = fi_zgdtxst0013-totfj.
      ENDIF.
      WRITE ld_totfj CURRENCY fi_zgdtxst0013-waers
            TO fe_espt-nilbill NO-GROUPING.

*-----Column 15
      IF fi_zgdtxst0013-ppnbmlast < 0.
        ld_ppnbmlast = ( -1 ) * fi_zgdtxst0013-ppnbmlast.
      ELSE.
        ld_ppnbmlast = fi_zgdtxst0013-ppnbmlast.
      ENDIF.
      WRITE ld_ppnbmlast CURRENCY fi_zgdtxst0013-waers
            TO fe_espt-nilppnbm NO-GROUPING.

  ENDCASE.



ENDFUNCTION.
