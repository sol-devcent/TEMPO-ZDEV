FUNCTION z_gdtxfc_exit_tax_period.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(FI_VBRK) LIKE  ZGDTXST0007 STRUCTURE  ZGDTXST0007 OPTIONAL
*"     VALUE(FI_BSEG) LIKE  ZGDTXST0008 STRUCTURE  ZGDTXST0008 OPTIONAL
*"     VALUE(FI_BUSLN) LIKE  ZGDTXDT0102-BUSLN
*"     VALUE(FI_FAKDAT) LIKE  ZGDTXDT0003-FAKDAT OPTIONAL
*"  EXPORTING
*"     VALUE(FE_FAKDAT) LIKE  ZGDTXDT0003-FAKDAT
*"     VALUE(FE_MASATX) LIKE  ZGDTXDT0003-MASATX
*"     VALUE(FE_GJAHR) LIKE  BKPF-GJAHR
*"  EXCEPTIONS
*"      FI_BSEG_CANNOT_BE_BLANK
*"      FI_VBRK_CANNOT_BE_BLANK
*"      BUSLINE_NOT_DEFINED
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
* The purpose of this user exit is to determine Faktur pajak date &    *
* Tax period of a processed faktur pajak                               *
* Business line has to be put as a mandatory parameter since this      *
* user exit is used for Billing processing both from SD which is using *
* structure ZGDTXST0007 and FI which is using structure ZGDTXST0008    *
*----------------------------------------------------------------------*

***added for Tempo
***Tempo use payment term to determine Tax period and FP date
  DATA ld_date LIKE sy-datum.
  DATA ld_last LIKE sy-datum.
  DATA ld_start_next LIKE sy-datum.
  DATA ld_last_next LIKE sy-datum.

  SELECT SINGLE datab
    FROM zproject
    INTO va_datab
    WHERE name EQ 'ZGDTAX'.

  CASE fi_busln.
    WHEN '99'.
      IF fi_bseg IS INITIAL.
        MESSAGE e000(zab) RAISING fi_bseg_cannot_be_blank.
      ENDIF.
      IF fi_bseg-ztag1 > 30.
        fi_bseg-ztag1 = 30.
      ENDIF.
*      fe_fakdat = fi_bseg-zfbdt.
      IF sy-datum GE va_datab.
        fe_fakdat = fi_bseg-budat.
      ELSE.
        fe_fakdat = fi_bseg-budat + fi_bseg-ztag1.
      ENDIF.
      ld_date = fi_bseg-budat.
    WHEN OTHERS.
      IF fi_vbrk IS INITIAL.
        MESSAGE e000(zab) RAISING fi_vbrk_cannot_be_blank.
      ENDIF.
      IF fi_vbrk-ztag1 > 30.
        fi_vbrk-ztag1 = 30.
      ENDIF.
      ld_date = fi_vbrk-fkdat.
      IF sy-datum GE va_datab.
        fe_fakdat = fi_vbrk-fkdat.
      ELSE.
        fe_fakdat = fi_vbrk-fkdat + fi_vbrk-ztag1.
      ENDIF.
  ENDCASE.

*-----Max 1 bulan takwim -- so max date is end of next month
**Get end of this month
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ld_date
    IMPORTING
      last_day_of_month = ld_last
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

**Get beginning of next month
  IF sy-datum GE va_datab.
    ld_start_next = ld_last.
  ELSE.
    ld_start_next = ld_last + 1.
  ENDIF.

**Get end of next month
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = ld_start_next
    IMPORTING
      last_day_of_month = ld_last_next
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

**Compare faktur date with end of next month,
**if smaller, get faktur date, if bigger get last of next month
  IF ld_last_next LT fe_fakdat.
    fe_fakdat = ld_last_next.
  ENDIF.

  fe_masatx = fe_fakdat+0(6).
  fe_gjahr  = fe_fakdat+0(4).
***end of Tempo addition

ENDFUNCTION.
