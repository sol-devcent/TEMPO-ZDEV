FORM print_b1.
DATA: L_CTR TYPE I, SW(1), L_CTR1 TYPE I.

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

  select * from zfvatb1 into table ta_b1
         where bukrs eq pa_bukrs
           and gsber eq pa_gsber
           and gjahr eq pa_gjahr
           and monat eq pa_monat.
*           and ( monat eq pa_monat or txdat in ta_date ).

  IF SY-SUBRC = 0.
  sort ta_b1 ascending by bukrs gsber gjahr txdat.
  ta_b1_hdr[] = ta_b1[].
  delete adjacent duplicates from ta_b1_hdr comparing bukrs gsber.
  loop at ta_b1_hdr.
    select single * from t001 where bukrs = ta_b1_hdr-bukrs.
    if sy-subrc <> 0.
       clear t001.
    endif.
    select single * from zftax where bukrs = ta_b1_hdr-bukrs
                                 and gsber = ta_b1_hdr-gsber.
    if sy-subrc <> 0.
       clear zftax.
    endif.

    clear ta_b1_dtl.
    refresh ta_b1_dtl.
    loop at ta_b1 where bukrs = ta_b1_hdr-bukrs
                    and gsber = ta_b1_hdr-gsber.
      clear ta_b1_dtl.
      ta_b1_dtl = ta_b1.
      append ta_b1_dtl.
    endloop.

    describe table ta_b1_dtl lines va_line.

    if xoption-tddest = space.
       call function 'OPEN_FORM'
         exporting
           form = 'ZFB1_NEW_1'
         importing
           result = xoption.
    else.
       xoption2-tddest = 'LP01'.
       call function 'OPEN_FORM'
         exporting
           form = 'ZFB1_NEW_1'
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
    va_no = 0.
    va_total = 0.
    va_tot_mts = 0.
    va_tot     = 0.
    va_positif = 0.
    va_negatif = 0.
    L_CTR = 0.
    SW = 1.
    clear: va_tot_41, va_tot_42, va_tot_43, va_tot_44, va_tot_47.

    SORT TA_B1_DTL BY SHKZG DESCENDING NAME1 TBELN TXDAT.
    loop at ta_b1_dtl.
       if ta_b1_dtl-txdat > ta_date-high.
           continue.
       Endif.
       Perform f_split_status.
       Perform f_check_mts.

       IF L_CTR > 59.
          VA_TOTAL = VA_POSITIF - VA_NEGATIF.
          WRITE VA_TOTAL TO TOTAL DECIMALS 0 CURRENCY 'IDR'.
          call function 'WRITE_FORM'
               exporting
                   window   = 'TOTAL'.
          call function 'WRITE_FORM'
               exporting
                   element  = 'HEADER6'
                   window   = 'MAIN'.
           L_CTR = 0.
           SW = 2.
           call function 'WRITE_FORM'
              exporting
                   element  = 'KOSONG'
                   window   = 'MAIN'.

       ENDIF.

       WRITE TA_B1_DTL-MWSBK TO MWSBK DECIMALS 0 CURRENCY 'IDR'.
       IF TA_B1_DTL-SHKZG EQ 'H'.
          ADD TA_B1_DTL-mwsbk TO VA_NEGATIF.
          SHIFT MWSBK LEFT DELETING LEADING space.
          CONCATENATE '(' MWSBK ')' INTO MWSBK SEPARATED BY SPACE.
       ELSE.
          ADD TA_B1_DTL-mwsbk TO VA_POSITIF.
       ENDIF.

       IF TA_B1_DTL-ZSTATUS = '47'.
             CONTINUE.
       ELSE.
             ADD  1   TO L_CTR.
             va_no    = va_no + 1.
             call function 'WRITE_FORM'
                 exporting
                    element  = 'DETAIL'
                    window   = 'MAIN'.
       ENDIF.

    endloop.
    VA_TOTAL = VA_POSITIF - VA_NEGATIF.
    WRITE VA_TOTAL TO TOTAL DECIMALS 0 CURRENCY 'IDR'.
*    va_total = va_total
*    sw = 1.
    if l_ctr > 30 AND L_CTR < 59.
       L_CTR = 59 - L_CTR.
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
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          ELEMENT = 'NEWPAGE'
          WINDOW = 'MAIN'
        EXCEPTIONS
         OTHERS = 1.
      call function 'WRITE_FORM'
         exporting
              element  = 'HEADER6'
              window   = 'MAIN'.
    endif.
    ENDLOOP.

    VA_MASUK = VA_TOT_POS41 + VA_TOT_POS42 + VA_TOT_POS43 +
               VA_TOT_POS44.
    VA_TOTAL = VA_POSITIF - VA_NEGATIF.
    VA_TOTAL1 = VA_MASUK - VA_NEGATIF + VA_TOT_POS47.
    VA_TOT_41 = VA_TOT_POS41.
    VA_TOT_42 = VA_TOT_POS42.
    VA_TOT_43 = VA_TOT_POS43.
    VA_TOT_44 = VA_TOT_POS44.
    VA_TOT_47 = VA_TOT_POS47.

    WRITE VA_MASUK TO MASUK DECIMALS 0 CURRENCY 'IDR'.
    WRITE VA_TOT_41 TO TOT_41 DECIMALS 0 CURRENCY 'IDR'.
    WRITE VA_TOT_42 TO TOT_42 DECIMALS 0 CURRENCY 'IDR'.
    WRITE VA_TOT_43 TO TOT_43 DECIMALS 0 CURRENCY 'IDR'.
    WRITE VA_TOT_44 TO TOT_44 DECIMALS 0 CURRENCY 'IDR'.
    WRITE VA_TOT_47 TO TOT_47 DECIMALS 0 CURRENCY 'IDR'.
    WRITE VA_TOTAL TO TOTAL DECIMALS 0 CURRENCY 'IDR'.
    WRITE VA_TOTAL1 TO TOTAL1 DECIMALS 0 CURRENCY 'IDR'.
    WRITE VA_NEGATIF TO NEGATIF DECIMALS 0 CURRENCY 'IDR'.
    SHIFT NEGATIF LEFT DELETING LEADING space.
    CONCATENATE '(' NEGATIF ')' INTO NEGATIF
      SEPARATED BY SPACE.

    IF VA_TOT_41 LT 0.
      SHIFT NEGATIF LEFT DELETING LEADING space.
      CONCATENATE '(' TOT_41 ')' INTO TOT_41
        SEPARATED BY SPACE.
    ELSEIF VA_TOT_42 LT 0.
      SHIFT NEGATIF LEFT DELETING LEADING space.
      CONCATENATE '(' TOT_42 ')' INTO TOT_42
        SEPARATED BY SPACE.
    ELSEIF VA_TOT_43 LT 0.
      SHIFT NEGATIF LEFT DELETING LEADING space.
      CONCATENATE '(' TOT_43 ')' INTO TOT_43
        SEPARATED BY SPACE.
    ELSEIF VA_TOT_44 LT 0.
      SHIFT NEGATIF LEFT DELETING LEADING space.
      CONCATENATE '(' TOT_44 ')' INTO TOT_44
        SEPARATED BY SPACE.
    ELSEIF VA_TOT_47 LT 0.
      SHIFT NEGATIF LEFT DELETING LEADING space.
      CONCATENATE '(' TOT_47 ')' INTO TOT_47
        SEPARATED BY SPACE.
    ENDIF.

    call function 'WRITE_FORM'
       exporting
            element = 'AKHIR'
            window  = 'AKHIR'.
    call function 'CLOSE_FORM'.
  ELSE.
    PERFORM NO_DATA_B1.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  NO_DATA_B1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM NO_DATA_B1.

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
      FORM   = 'ZFB1_NEW_1'
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

ENDFORM.                    " NO_DATA_B1

*&---------------------------------------------------------------------*
*&      Form  f_split_status
*&---------------------------------------------------------------------*
FORM f_split_status.
       case ta_b1_dtl-zstatus.
            when '41'.
               IF TA_B1_DTL-SHKZG = 'S'.
                 ADD ta_b1_dtl-mwsbk TO va_tot_POS41.
               ELSE.
                 ADD ta_b1_dtl-mwsbk TO va_tot_NEG41.
               ENDIF.
            when '42'.
               IF TA_B1_DTL-SHKZG = 'S'.
                 ADD ta_b1_dtl-mwsbk TO va_tot_POS42.
               ELSE.
                 ADD ta_b1_dtl-mwsbk TO va_tot_NEG42.
               ENDIF.
            when '43'.
               IF TA_B1_DTL-SHKZG = 'S'.
                 ADD ta_b1_dtl-mwsbk TO va_tot_POS43.
               ELSE.
                 ADD ta_b1_dtl-mwsbk TO va_tot_NEG43.
               ENDIF.
            when '44'.
               IF TA_B1_DTL-SHKZG = 'S'.
                 ADD ta_b1_dtl-mwsbk TO va_tot_POS44.
               ELSE.
                 ADD ta_b1_dtl-mwsbk TO va_tot_NEG44.
               ENDIF.
            when '47'.
               IF TA_B1_DTL-SHKZG = 'S'.
                 ADD ta_b1_dtl-mwsbk TO va_tot_POS47.
               ELSE.
                 ADD ta_b1_dtl-mwsbk TO va_tot_NEG47.
               ENDIF.
       endcase.

ENDFORM.                    " f_split_status

*&---------------------------------------------------------------------*
*&      Form  f_check_mts
*&---------------------------------------------------------------------*
FORM f_check_mts.
* TAMBAHAN KONDISI UNTUK 'MTS' 18122002
        IF TA_B1_DTL-TXDAT+4(2) <> PA_MONAT.
           ta_b1_dtl-REMARK = 'MTS'.
           va_tot_mts = va_tot_mts + ta_b1_dtl-mwsbk.
           IF TA_B1_DTL-ZSTATUS EQ '42'.
              MOVE '41' TO TA_B1_DTL-ZSTATUS.
           ELSEIF TA_B1_DTL-ZSTATUS EQ '44'.
              MOVE '43' TO TA_B1_DTL-ZSTATUS.
           ENDIF.
        ELSE.
          ta_b1_dtl-REMARK = ' '.
          va_tot = va_tot + ta_b1_dtl-mwsbk.
          IF TA_B1_DTL-ZSTATUS EQ '41'.
             MOVE '42' TO TA_B1_DTL-ZSTATUS.
          ELSEIF TA_B1_DTL-ZSTATUS EQ '43'.
             MOVE '44' TO TA_B1_DTL-ZSTATUS.
          ENDIF.
        ENDIF.
        UPDATE ZFVATB1 SET ZSTATUS = TA_B1_DTL-ZSTATUS
               WHERE BUKRS EQ PA_BUKRS AND
                     GSBER EQ PA_GSBER AND
                     GJAHR EQ PA_GJAHR AND
                     MONAT EQ PA_MONAT AND
                     TBELN EQ TA_B1_DTL-TBELN.
* END TAMBAHAN

ENDFORM.                    " f_check_mts
