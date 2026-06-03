FORM print_b4.
DATA: L_CTR TYPE I, SW(1).
  ta_date-sign   = 'I'.
  ta_date-option = 'BT'.
  concatenate pa_gjahr pa_monat '01' into ta_date-low.
  call function 'LAST_DAY_OF_MONTHS'
       exporting
          day_in = ta_date-low
       importing
          LAST_DAY_OF_MONTH = ta_date-high.
  append ta_date.

  va_thn = pa_gjahr.
  case pa_monat.
    when '01' or '1 ' or ' 1'.
       va_prd = 'Januari'.
    when '02' or '2 ' or ' 2'.
       va_prd = 'Pebruari'.
    when '03' or '3 ' or ' 3'.
       va_prd = 'Maret'.
    when '04' or '4 ' or ' 4'.
       va_prd = 'April'.
    when '05' or '5 ' or ' 5'.
       va_prd = 'Mei'.
    when '06' or '6 ' or ' 6'.
       va_prd = 'Juni'.
    when '07' or '7 ' or ' 7'.
       va_prd = 'Juli'.
    when '08' or '8 ' or ' 8'.
       va_prd = 'Agustus'.
    when '09' or '9 ' or ' 9'.
       va_prd = 'September'.
    when '10'.
       va_prd = 'Oktober'.
    when '11'.
       va_prd = 'Nopember'.
    when '12'.
       va_prd = 'Desember'.
  endcase.

  select * from zfvatb4 into table ta_b4
         where bukrs eq pa_bukrs
           and gsber eq pa_gsber
           and gjahr eq pa_gjahr
           and monat eq pa_monat.
*           and ( monat eq pa_monat or txdat in ta_date ).
  IF SY-SUBRC = 0.
  sort ta_b4 ascending by bukrs gsber gjahr txdat.
  ta_b4_hdr[] = ta_b4[].
  delete adjacent duplicates from ta_b4_hdr comparing bukrs gsber.

  loop at ta_b4_hdr.
      select single * from t001 where bukrs = ta_b4_hdr-bukrs.
      if sy-subrc <> 0.
         clear t001.
      endif.
      select single * from zftax where bukrs = ta_b4_hdr-bukrs
                                   and gsber = ta_b4_hdr-gsber.
      if sy-subrc <> 0.
         clear zftax.
      endif.

      clear ta_b4_dtl.
      refresh ta_b4_dtl.
      loop at ta_b4 where bukrs = ta_b4_hdr-bukrs
                      and gsber = ta_b4_hdr-gsber.
        clear ta_b4_dtl.
        ta_b4_dtl = ta_b4.
        append ta_b4_dtl.
    endloop.
    describe table ta_b4_dtl lines va_line.

    if xoption-tddest = space.
       call function 'OPEN_FORM'
         exporting
           form = 'ZFB4_NEW_1'
         importing
           result = xoption.
    else.
       xoption2-tddest = 'LP01'.
       call function 'OPEN_FORM'
         exporting
           form = 'ZFB4_NEW_1'
           options = xoption2
           dialog = ' '.
    endif.

    call function 'WRITE_FORM'
         exporting
              window   = 'HEADER1'.
    call function 'WRITE_FORM'
         exporting
              window = 'HEADER2'.
    call function 'WRITE_FORM'
         exporting
              window = 'HEADER3'.
    call function 'WRITE_FORM'
         exporting
              window = 'HEADER4'.
    call function 'WRITE_FORM'
         exporting
              element = 'HEADER5'
              window  = 'MAIN'.

    CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          ELEMENT = 'KOLOM'
          WINDOW  = 'KOLOM'.

    va_no = 0.
    va_total = 0.
    va_tot_mts = 0.
    va_tot     = 0.
    va_positif = 0.
    va_negatif = 0.
    L_CTR = 0.
    SW = 1.
    SORT TA_B4_DTL BY NAME1 TBELN TXDAT.
    loop at ta_b4_dtl.
       if ta_b4_dtl-txdat > ta_date-high.
*          continue.
       Endif.
       va_no    = va_no + 1.
       va_total = va_total + ta_b4_dtl-mwsbk.
       if ta_b4_dtl-txdat in ta_date.
          ta_b4_dtl-REMARK = ' '.
          va_tot = va_tot + ta_b4_dtl-mwsbk.
       Else.
          ta_b4_dtl-REMARK = 'MTS'.
          va_tot_mts = va_tot_mts + ta_b4_dtl-mwsbk.
       Endif.

       IF L_CTR > 65.
            call function 'WRITE_FORM'
               exporting
                  element  = 'HEADER6'
                  window   = 'MAIN'.
            L_CTR = 0.
       ENDIF.

      WRITE TA_B4_DTL-MWSBK TO MWSBK DECIMALS 0 CURRENCY 'IDR'.
* SHKZG
      IF TA_B4_DTL-SHKZG EQ 'H'.
        ADD TA_B4_DTL-mwsbk TO VA_NEGATIF.
        SHIFT MWSBK LEFT DELETING LEADING space.
        CONCATENATE '(' MWSBK ')' INTO MWSBK SEPARATED BY SPACE.
      ELSE.
        ADD TA_B4_DTL-mwsbk TO VA_POSITIF.
      ENDIF.

      ADD 1 TO L_CTR.
      call function 'WRITE_FORM'
            exporting
              element  = 'DETAIL'
              window   = 'MAIN'.
    endloop.
    if l_ctr > 50 AND L_CTR < 67.
       L_CTR = 67 - L_CTR.
       DO L_CTR TIMES.
            call function 'WRITE_FORM'
               exporting
                   element  = 'KOSONG'
                   window   = 'MAIN'.
            SW = 2.

       ENDDO.
    ELSE.
       call function 'WRITE_FORM'
         exporting
              window   = 'TOTAL'.
    ENDIF.
    IF SW = 2.
          call function 'WRITE_FORM'
             exporting
                  element = 'NEWPAGE'
                  window  = 'MAIN'.
          call function 'WRITE_FORM'
             exporting
                  element  = 'HEADER6'
                  window   = 'MAIN'.
    ENDIF.
*    if l_ctr > 49.
*      call function 'WRITE_FORM'
*         exporting
*              element = 'NEWPAGE'
*              window  = 'MAIN'.
*      call function 'WRITE_FORM'
*         exporting
*              element  = 'HEADER6'
*              window   = 'MAIN'.
*    endif.
  endloop.

  VA_TOTAL = VA_POSITIF - VA_NEGATIF.
  WRITE VA_TOTAL TO TOTAL DECIMALS 0 CURRENCY 'IDR'.

  call function 'WRITE_FORM'
      exporting
          element = 'AKHIR'
          window  = 'AKHIR'.

  Call function 'CLOSE_FORM'.

  ELSE.
    PERFORM NO_DATA_B4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  NO_DATA_B4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM NO_DATA_B4.

    select single * from t001 where bukrs = PA_bukrs.
    if sy-subrc <> 0.
       clear t001.
    endif.
    select single * from zftax where bukrs = PA_bukrs
                                 and gsber = PA_gsber.
    if sy-subrc <> 0.
       clear zftax.
    endif.

  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      FORM   = 'ZFB4_NEW_1'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'HEADER1'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'LOGO'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'NOMOR'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'HEADER2'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'HEADER3'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      WINDOW = 'HEADER4'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'HEADER5'
      WINDOW = 'MAIN'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'KOLOM'
      WINDOW = 'KOLOM'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'LINE1'
      WINDOW = 'LINE'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'NIHIL'
      WINDOW = 'MAIN'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'AKHIR1'
      WINDOW = 'AKHIR1'
    EXCEPTIONS
     OTHERS = 1.

 CALL FUNCTION 'CLOSE_FORM'.

ENDFORM.                    " NO_DATA_B4
