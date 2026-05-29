REPORT ZTEST no standard page heading
                                  line-size  244.

Tables: ZSL_DSALES, ZSL_Hsales, tgsbt, TVBUR, TVKBT, T001W.
Types: Begin of t_itab,
           Vkorg like zsl_hsales-vkorg,
           Plant like zsl_hsales-plant,
           Vkbur like zsl_hsales-vkbur,
           Vbeln like zsl_hsales-vbeln,
           VBtyp like zsl_hsales-vbtyp,
           z_uplod like zsl_hsales-z_uplod,
           fkdat like zsl_hsales-fkdat,
           bldat like zsl_hsales-bldat,
           fkart like zsl_hsales-fkart,
           spdot like zsl_hsales-spdot,
           account_no like zsl_hsales-account_no,
           cogs_j like zsl_hsales-cogs_j,
           staacc like zsl_hsales-staacc,
           grswr  like zsl_hsales-grswr,
           stagi  like zsl_dsales-stagi,
       End of t_itab.

Types: Begin of t_itab1,
           Vkorg like zsl_hsales-vkorg,
           Vkbur like zsl_hsales-vkbur,
           SPDO(22),
           h_dok_ok_gi type i,
           h_dok_fail_gi type i,
           h_dok_ok_cogs type i,
           h_dok_fail_cogs type i,
           h_dok_ok_sales type i,
           h_dok_fail_sales type i,
           d_dok_ok_gi type i,
           d_dok_fail_gi type i,
           d_dok_ok_cogs type i,
           d_dok_fail_cogs type i,
           d_dok_ok_sales type i,
           d_dok_fail_sales type i,
           g_dok_ok_cogs type p,
           g_dok_fail_cogs type p,
           g_dok_ok_sales type p,
           g_dok_fail_sales type p,
       End of t_itab1.
 Data: i_itab type t_itab occurs 0,
       wa_itab type t_itab,
       i_result type t_itab1 occurs 0,
       wa_result1 type t_itab1,
       wa_result type t_itab1,
       wa_subtotal type t_itab1,
       wa_grandtotal type t_itab1,
       va_nou type i.
data:
       v_line_size type i,
       v_line_size_sum type i,
       c1    type i,
       c2    type i,
       c3    type i,
       c4    type i,  w0    type i,
       w1    type i,  w2    type i,  w3    type i,  w4    type i,
       w5    type i,  w6    type i,  w7    type i,  w8    type i,
       w9    type i,  w10   type i,  w11   type i,  w12   type i,
       w13   type i,  w14   type i,  w15   type i,  w16   type i,
       w17   type i,  w18   type i,  w19   type i,  w19a  type i,
       w20   type i,  w17a  type i,
       w21   type i,  w22   type i,  w23   type i,  w24   type i,
       w25   type i,  w26   type i,  w27   type i,  w28   type i,
       w29   type i,  w30   type i,  w31   type i,  w32   type i,
       w33   type i,  w34   type i,  w35   type i.


SELECTION-SCREEN BEGIN OF BLOCK AAA WITH FRAME TITLE TEXT-AAA.
Parameters    so_vkorg like zsl_hsales-vkorg obligatory default '8020'.
select-options : so_plant for T001W-werks,
                 so_vkbur for TVBUR-vkbur,
                 so_fkdat for zsl_hsales-fkdat,
                 so_vbeln for zsl_hsales-vbeln,
                 so_bldat for zsl_hsales-bldat,
                 so_fkart for zsl_hsales-fkart,
                 so_spdot for zsl_hsales-spdot,
                 so_zup for zsl_hsales-z_uplod.
selection-screen skip.


SELECTION-SCREEN END OF BLOCK AAA.
************************************************************************
* PROGRAM                                                              *
************************************************************************
************************************************************************
* INITIALIZATION
************************************************************************
INITIALIZATION.
Perform f_init_column.
************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.

Select     a~Vkorg
           a~Plant
           a~Vkbur
           a~Vbeln
           a~VBtyp
           a~z_uplod
           a~fkdat
           a~bldat
           a~fkart
           a~spdot
           a~account_no
           a~cogs_j
           a~staacc
           a~grswr
           b~stagi
           INTO CORRESPONDING FIELDS OF TABLE i_itab
           From zsl_hsales as a join zsl_dsales as b
                 on a~vbeln = b~vbeln and
                    a~vbtyp = b~vbtyp and
                    a~z_uplod = b~z_uplod and
                    a~gjahr   =  b~gjahr
           Where a~vkorg      eq so_vkorg      and
                 a~plant      in so_plant      and
                 a~vkbur      in so_vkbur      and
                 a~fkdat      in so_fkdat      and
                 a~vbeln      in so_vbeln      and
                 a~bldat      in so_bldat      and
                 a~fkart      in so_fkart      and
                 a~spdot      in so_spdot      and
                 a~z_uplod    in so_zup
           Order by a~vkorg a~vkbur a~fkdat a~fkart a~spdot
                    a~vbeln a~vbtyp.

if sy-subrc ne 0.
   Write: / 'No Data'.
   Exit.
Endif.
Clear: wa_itab, wa_result, wa_subtotal, wa_grandtotal, i_result.
*Sort i_itab

Loop at i_itab into wa_itab.
     On change of wa_itab-vkorg or
                  wa_itab-vkbur or
                  wa_itab-fkdat or
                  wa_itab-fkart or
                  wa_itab-spdot.
          if not wa_result is initial.
              append wa_result to i_result.
              clear wa_result.
          Endif.
     Endon.
     On change of wa_itab-vkorg or
                  wa_itab-vkbur or
                  wa_itab-fkdat or
                  wa_itab-fkart or
                  wa_itab-spdot or
                  wa_itab-vbeln or
                  wa_itab-vbtyp.
          Perform f_calculate_header.
     Endon.
     Move wa_itab-vkorg to wa_result-vkorg.
     move wa_itab-vkbur to wa_result-vkbur.
     Concatenate wa_itab-vkbur wa_itab-fkart wa_itab-spdot
            into wa_result-spdo separated by '-'.
     Perform f_calculate_detail.
Endloop.
append wa_result to i_result.
data: sw(1), va_text(30).
c1 = 2.
va_nou = 0.
sw = 0.
Sort i_result by vkbur spdo.
Loop at i_result into wa_result.
      at new vkbur.
          select single * from TVKBT where vkbur eq wa_result-vkbur and
                                ( spras eq 'EN' or spras eq 'E' ).

          concatenate wa_result-vkbur TVKBT-BEZEI
          into va_text separated by '-'.
         add 1 to va_nou.
         write: / sy-vline.
         c1 = 2.
         write at c1(w1) va_nou no-gap  .  c1 = c1 + w1.
         write at c1(1)  sy-vline no-gap. c1 = c1 + 1.

         write at c1(w2) va_text no-gap . c1 = c1 + w2.
         write at c1(1)  sy-vline no-gap. c1 = c1 + 1.
         sw = 1.
      endat.
      if sw ne 1.
         write: / sy-vline.
         c1 = 2.
         c1 = c1 + w1.
         write at c1(1)  sy-vline no-gap. c1 = c1 + 1.

         c1 = c1 + w2.
         write at c1(1)  sy-vline no-gap. c1 = c1 + 1.
      Else.
         sw = 0.
      Endif.

      Perform f_write_line.
      Add wa_result-h_dok_ok_gi to wa_subtotal-h_dok_ok_gi.
      Add wa_result-h_dok_fail_gi to wa_subtotal-h_dok_fail_gi.
      Add wa_result-h_dok_ok_cogs to wa_subtotal-h_dok_ok_cogs.
      Add wa_result-h_dok_fail_cogs to wa_subtotal-h_dok_fail_cogs.
      Add wa_result-h_dok_ok_sales to wa_subtotal-h_dok_ok_sales.
      Add wa_result-h_dok_fail_sales to wa_subtotal-h_dok_fail_sales.
      Add wa_result-d_dok_ok_gi to wa_subtotal-d_dok_ok_gi.
      Add wa_result-d_dok_fail_gi to wa_subtotal-d_dok_fail_gi.
      Add wa_result-d_dok_ok_cogs to wa_subtotal-d_dok_ok_cogs.
      Add wa_result-d_dok_fail_cogs to wa_subtotal-d_dok_fail_cogs.
      Add wa_result-d_dok_ok_sales to wa_subtotal-d_dok_ok_sales.
      Add wa_result-d_dok_fail_sales to wa_subtotal-d_dok_fail_sales.
      Add wa_result-g_dok_ok_cogs to wa_subtotal-g_dok_ok_cogs.
      Add wa_result-g_dok_fail_cogs to wa_subtotal-g_dok_fail_cogs.
      Add wa_result-g_dok_ok_sales to wa_subtotal-g_dok_ok_sales.
      Add wa_result-g_dok_fail_sales to wa_subtotal-g_dok_fail_sales.

      Add wa_result-h_dok_ok_gi to wa_grandtotal-h_dok_ok_gi.
      Add wa_result-h_dok_fail_gi to wa_grandtotal-h_dok_fail_gi.
      Add wa_result-h_dok_ok_cogs to wa_grandtotal-h_dok_ok_cogs.
      Add wa_result-h_dok_fail_cogs to wa_grandtotal-h_dok_fail_cogs.
      Add wa_result-h_dok_ok_sales to wa_grandtotal-h_dok_ok_sales.
      Add wa_result-h_dok_fail_sales to wa_grandtotal-h_dok_fail_sales.
      Add wa_result-d_dok_ok_gi to wa_grandtotal-d_dok_ok_gi.
      Add wa_result-d_dok_fail_gi to wa_grandtotal-d_dok_fail_gi.
      Add wa_result-d_dok_ok_cogs to wa_grandtotal-d_dok_ok_cogs.
      Add wa_result-d_dok_fail_cogs to wa_grandtotal-d_dok_fail_cogs.
      Add wa_result-d_dok_ok_sales to wa_grandtotal-d_dok_ok_sales.
      Add wa_result-d_dok_fail_sales to wa_grandtotal-d_dok_fail_sales.
      Add wa_result-g_dok_ok_cogs to wa_grandtotal-g_dok_ok_cogs.
      Add wa_result-g_dok_fail_cogs to wa_grandtotal-g_dok_fail_cogs.
      Add wa_result-g_dok_ok_sales to wa_grandtotal-g_dok_ok_sales.
      Add wa_result-g_dok_fail_sales to wa_grandtotal-g_dok_fail_sales.
      at End of vkbur.
          Write: / sy-uline.
          Move-corresponding wa_subtotal to wa_result.
          Clear wa_subtotal.
          write: / sy-vline.
          c1 = 2.
          w0 = w1 + w2 + 1.
          Concatenate 'Sub Total' va_text into va_text
              separated by space.
          write at c1(w0) va_text no-gap . c1 = c1 + w0.
          write at c1(1)  sy-vline no-gap. c1 = c1 + 1.
          Clear wa_result-spdo.
          Perform f_write_line.
          Write: / sy-uline.
      Endat.
Endloop.
          Write: / sy-uline.
          Move-corresponding wa_grandtotal to wa_result.
          write: / sy-vline.
          c1 = 2.
          w0 = w1 + w2 + 1.

          write at c1(w0) 'Grand Total ' no-gap . c1 = c1 + w0.
          write at c1(1)  sy-vline no-gap. c1 = c1 + 1.
          Clear wa_result-spdo.
          Perform f_write_line.
          Write: / sy-uline.
Top-of-page.
    Perform f_write_header.
End-of-page.


************************************************************************
* AT LINE-SELECTION.
************************************************************************
AT LINE-SELECTION.
data: va_value(20),
      va_fieldname(30),
      va_fkart like zsl_hsales-fkart,
      va_vkbur like zsl_hsales-vkbur,
      va_spdot like zsl_hsales-spdot.

if sy-lsind = 1.
   get cursor field va_fieldname value va_value.
   case va_fieldname.
          when 'WA_RESULT-SPDO'.
              va_vkbur = va_value(4).
              va_fkart = va_value+5(4).
              va_spdot = va_value+10(8).
*              Write: / va_vkbur, va_fkart, va_spdot.
*              write: / sy-LISEL.
   c1 = 2.
   write: / sy-uline.
   Write: / sy-vline no-gap.
   write at c1(w6) 'Billing No' no-gap centered. c1 = c1 + w6.

   write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
   write at c1(w7)  'Account No' no-gap centered. c1 = c1 + w7.

   write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
   write at c1(w8)  'COGS No' no-gap centered. c1 = c1 + w8.

   write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
   write at c1(w9)  'Tgl Doc.' no-gap centered. c1 = c1 + w9.

   write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
   write at c1(w10) 'Nama Customer'   no-gap . c1 = c1 + w10.

   write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
   write at c1(w10) 'No. Faktur Pajak' no-gap . c1 = c1 + w10.

   write at c1(1)    sy-vline no-gap. c1 = c1 + 1.
   write at c1(w11)  'Gross Sales' no-gap . c1 = c1 + w11.

   write at c1(1)    sy-vline no-gap. c1 = c1 + 1.
   write at c1(w11)  'Net Sales' no-gap . c1 = c1 + w11.

   write at c1(1)    sy-vline no-gap. c1 = c1 + 1.
   write at c1(w11)  'PPN ' no-gap . c1 = c1 + w11.

   write at c1(1)    sy-vline no-gap. c1 = c1 + 1.
   write at c1(w9)  'Tgl Proses' no-gap . c1 = c1 + w9.
   write: / sy-uline.
              Loop at i_itab into wa_itab where vkbur = va_vkbur and
                                                fkart = va_fkart and
                                                spdot = va_spdot.

                   On change of wa_itab-vkorg or
                                wa_itab-vkbur or
                                wa_itab-fkdat or
                                wa_itab-fkart or
                                wa_itab-spdot or
                                wa_itab-vbeln or
                                wa_itab-vbtyp.
                        Perform f_write_detail.
                   Endon.
              Endloop.
   write: / sy-uline.

   Endcase.
Endif.

*&---------------------------------------------------------------------*
*&      Form  f_write_header
*&---------------------------------------------------------------------*
FORM f_write_header.
data l_VTEXT like tvkot-VTEXT.


       Select Single VTEXT into l_VTEXT From TVKOT
              where  VKORG =  so_vkorg and
                     Spras = 'EN'.

    Format color 5.
    Write: / 'Sales Organisation : ', so_vkorg, ' - ', l_vtext.
    If so_fkdat is initial.
       Write: / 'All Periode'.
    Else.
       Write: / 'Periode : ', so_fkdat-low, ' - ', so_fkdat-high.
    Endif.
    Write: / 'User Id', sy-uname.
    Format color 3.
         c1 = 2.
         write: / sy-uline.
         write: / sy-vline.
         write at c1(w1)  'No' no-gap  centered.  c1 = c1 + w1.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         write at c1(w2)  'Cabang' no-gap  centered.   c1 = c1 + w2.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         write at c1(w3)  'SPDO' no-gap  centered.   c1 = c1 + w3.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         w0 = w4 * 6 + 5.
         write at c1(w0)  'Header' no-gap  centered.   c1 = c1 + w0.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         write at c1(w0)  'Detail' no-gap  centered.   c1 = c1 + w0.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         w0 = w5 * 4 + 3.
         write at c1(w0)  'Gross Sales' no-gap  centered. c1 = c1 + w0.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         c1 = 2.

         write: / sy-uline.
         write: / sy-vline.
         c1 = c1 + w1.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         c1 = c1 + w2.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         c1 = c1 + w3.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         w0 = w4 * 2 + 1.
         write at c1(w0)  'Proses GI' no-gap centered. c1 = c1 + w0.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
         write at c1(w0)  'Posting COGS' no-gap centered. c1 = c1 + w0.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
         write at c1(w0)  'Posting Sales' no-gap centered. c1 = c1 + w0.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
         write at c1(w0)  'Proses GI' no-gap centered. c1 = c1 + w0.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
         write at c1(w0)  'Posting COGS' no-gap centered. c1 = c1 + w0.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
         write at c1(w0)  'Posting Sales' no-gap centered. c1 = c1 + w0.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
         w0 = w5 * 2 + 1.
         write at c1(w0)  'Posting COGS' no-gap centered. c1 = c1 + w0.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
         write at c1(w0)  'Posting Sales' no-gap centered. c1 = c1 + w0.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
         c1 = 2.

         write: / sy-uline.
         write: / sy-vline.
         c1 = c1 + w1.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         c1 = c1 + w2.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         c1 = c1 + w3.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         write at c1(w4)  'Dok Ok' no-gap  centered.   c1 = c1 + w4.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         write at c1(w4)  'Dok Fail' no-gap  centered.   c1 = c1 + w4.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         write at c1(w4)  'Dok Ok' no-gap  centered.   c1 = c1 + w4.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         write at c1(w4)  'Dok Fail' no-gap  centered.   c1 = c1 + w4.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
         write at c1(w4)  'Dok Ok' no-gap  centered.   c1 = c1 + w4.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         write at c1(w4)  'Dok Fail' no-gap  centered.   c1 = c1 + w4.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
         write at c1(w4)  'Dok Ok' no-gap  centered.   c1 = c1 + w4.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         write at c1(w4)  'Dok Fail' no-gap  centered.   c1 = c1 + w4.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
         write at c1(w4)  'Dok Ok' no-gap  centered.   c1 = c1 + w4.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         write at c1(w4)  'Dok Fail' no-gap  centered.   c1 = c1 + w4.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
         write at c1(w4)  'Dok Ok' no-gap  centered.   c1 = c1 + w4.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         write at c1(w4)  'Dok Fail' no-gap  centered.   c1 = c1 + w4.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
         write at c1(w5)  'Dok Ok' no-gap  centered.   c1 = c1 + w5.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         write at c1(w5)  'Dok Fail' no-gap  centered.   c1 = c1 + w5.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
         write at c1(w5)  'Dok Ok' no-gap  centered.   c1 = c1 + w5.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         write at c1(w5)  'Dok Fail' no-gap  centered.   c1 = c1 + w5.
         write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

         write: / sy-uline.
ENDFORM.                    " f_write_header
*&---------------------------------------------------------------------*
*&      Form  f_Write_line
*&---------------------------------------------------------------------*
FORM f_Write_line.


   write at c1(w3) wa_result-spdo no-gap. c1 = c1 + w3.
   write at c1(1)  sy-vline no-gap. c1 = c1 + 1.

   write at c1(w4) wa_result-h_dok_ok_gi no-gap  centered. c1 = c1 + w4.
   write at c1(1)  sy-vline no-gap. c1 = c1 + 1.

   write at c1(w4) wa_result-h_dok_fail_gi no-gap centered. c1 = c1 + w4
.
   write at c1(1)  sy-vline no-gap. c1 = c1 + 1.

   write at c1(w4) wa_result-h_dok_ok_cogs no-gap centered. c1 = c1 + w4
.
   write at c1(1)  sy-vline no-gap. c1 = c1 + 1.

 write at c1(w4) wa_result-h_dok_fail_cogs no-gap centered. c1 = c1 + w4
.
   write at c1(1) sy-vline no-gap. c1 = c1 + 1.
 write at c1(w4) wa_result-h_dok_ok_sales no-gap centered. c1 = c1 + w4.
   write at c1(1) sy-vline no-gap. c1 = c1 + 1.

write at c1(w4) wa_result-h_dok_fail_sales no-gap centered. c1 = c1 + w4
.
   write at c1(1) sy-vline no-gap. c1 = c1 + 1.
   write at c1(w4)  wa_result-d_dok_ok_gi no-gap centered. c1 = c1 + w4.
   write at c1(1) sy-vline no-gap. c1 = c1 + 1.

   write at c1(w4) wa_result-d_dok_fail_gi no-gap centered. c1 = c1 + w4
.
   write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
   write at c1(w4) wa_result-d_dok_ok_cogs no-gap centered. c1 = c1 + w4
.
   write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

 write at c1(w4) wa_result-d_dok_fail_cogs no-gap centered. c1 = c1 + w4
.
   write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
 write at c1(w4) wa_result-d_dok_ok_sales no-gap centered. c1 = c1 + w4.
   write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

write at c1(w4) wa_result-d_dok_fail_sales no-gap centered. c1 = c1 + w4
.
   write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
   write at c1(w5)  wa_result-g_dok_ok_cogs no-gap . c1 = c1 + w5.
   write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

 write at c1(w5) wa_result-g_dok_fail_cogs no-gap . c1 = c1 + w5.
   write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
  write at c1(w5) wa_result-g_dok_ok_sales no-gap . c1 = c1 + w5.
   write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

write at c1(w5) wa_result-g_dok_fail_sales no-gap .  c1 = c1 + w5.
   write at c1(1)   sy-vline no-gap. c1 = c1 + 1.

*   write: / sy-uline.


ENDFORM.                    " f_Write_line
*&---------------------------------------------------------------------*
*&      Form  f_calculate
*&---------------------------------------------------------------------*
FORM f_calculate.
ENDFORM.                    " f_calculate
*&---------------------------------------------------------------------*
*&      Form  f_init_column
*&---------------------------------------------------------------------*
FORM f_init_column.
  w1   =   4.      w11 = 15.      w21 = 12.      w31 = 10.
  w2   =  25.      w12 = 15.      w22 = 10.      w32 = 12.
  w3   =  15.      w13 = 6.      w23 = 10.      w33 = 12.
  w4   =  10.      w14 = 15.      w24 = 12.      w34 = 10.
  w5   =  15.      w15 = 10.      w25 = 12.      w35 = 10.
  w6   =  18.      w16 = 12.      w26 = 10.
  w7   =  15.      w17 = 12.      w27 = 10.      w19a = 12.
  w8   =  15.      w18 = 10.      w28 = 12.
  w9   =  10.      w19 = 10.      w29 = 12.
  w10  =  20.      w20 = 12.      w30 = 10.

ENDFORM.                    " f_init_column
*&---------------------------------------------------------------------*
*&      Form  f_calculate_header
*&---------------------------------------------------------------------*
FORM f_calculate_header.
      if wa_itab-VBtyp = 'O'.
          wa_itab-grswr = wa_itab-grswr * -100.
      Else.
          wa_itab-grswr = wa_itab-grswr * 100.
      Endif.
     if wa_itab-stagi = 'X'.
        add 1 to wa_result-h_dok_ok_gi.
     Else.
        add 1 to wa_result-h_dok_fail_gi.
     Endif.
     if wa_itab-account_no ne space.
        add 1 to wa_result-h_dok_ok_sales.
        add wa_itab-grswr to wa_result-g_dok_ok_sales.
     Else.
        add 1 to wa_result-h_dok_fail_sales.
        add wa_itab-grswr to wa_result-g_dok_fail_sales.
     Endif.
     if wa_itab-cogs_j ne space.
        add 1 to wa_result-h_dok_ok_cogs.
        add wa_itab-grswr to wa_result-g_dok_ok_cogs.
     Else.
        add 1 to wa_result-h_dok_fail_cogs.
        add wa_itab-grswr to wa_result-g_dok_fail_cogs.
     Endif.

ENDFORM.                    " f_calculate_header
*&---------------------------------------------------------------------*
*&      Form  f_calculate_detail
*&---------------------------------------------------------------------*
FORM f_calculate_detail.
     if wa_itab-stagi = 'X'.
        add 1 to wa_result-d_dok_ok_gi.
     Else.
        add 1 to wa_result-d_dok_fail_gi.
     Endif.
     if wa_itab-account_no ne space.
        add 1 to wa_result-d_dok_ok_sales.
     Else.
        add 1 to wa_result-d_dok_fail_sales.
     Endif.
     if wa_itab-cogs_j ne space.
        add 1 to wa_result-d_dok_ok_cogs.
     Else.
        add 1 to wa_result-d_dok_fail_cogs.
     Endif.

ENDFORM.                    " f_calculate_detail
*&---------------------------------------------------------------------*
*&      Form  f_write_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_detail.
Data: vatdt  like zfvato-vatdt,
      erdat  like zfvato-erdat,
      vatno  like zfvato-vatno,
      TKWERT like zfvato-TKWERT,
      NETWR  like zfvato-NETWR,
      MWSBK  like zfvato-MWSBK,
      name_co like zfvato-name_co,
      va_vrtnr(20).

  Clear: erdat, vatdt, vatno, TKWERT, NETWR,  MWSBK,  name_co, va_vrtnr.
   Select single erdat vatdt vatno TKWERT NETWR  MWSBK  name_co
          into (erdat, vatdt, vatno, TKWERT, NETWR,  MWSBK,  name_co)
          from zfvato where zuonr eq wa_itab-vbeln.

   TKWERT  = TKWERT * 100.
   NETWR   = NETWR  * 100.
   MWSBK   = MWSBK  * 100.
   if vatno ne 0.
      concatenate 'CWBTO-011-' vatno into va_vrtnr.
   endif.
   Write: / sy-vline.
   c1 = 2.
   write at c1(w6) wa_itab-vbeln no-gap centered. c1 = c1 + w6.

   write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
   write at c1(w7)  wa_itab-account_no no-gap . c1 = c1 + w7.

   write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
   write at c1(w8)  wa_itab-COGS_J no-gap . c1 = c1 + w8.

   write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
   write at c1(w9)  wa_itab-bldat no-gap . c1 = c1 + w9.

   write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
   write at c1(w10) name_co   no-gap . c1 = c1 + w10.

   write at c1(1)   sy-vline no-gap. c1 = c1 + 1.
   write at c1(w10) va_vrtnr no-gap . c1 = c1 + w10.

   write at c1(1)    sy-vline no-gap. c1 = c1 + 1.
   write at c1(w11)  TKWERT no-gap . c1 = c1 + w11.

   write at c1(1)    sy-vline no-gap. c1 = c1 + 1.
   write at c1(w11)  NETWR no-gap . c1 = c1 + w11.

   write at c1(1)    sy-vline no-gap. c1 = c1 + 1.
   write at c1(w11)  MWSBK no-gap . c1 = c1 + w11.

   write at c1(1)    sy-vline no-gap. c1 = c1 + 1.
   write at c1(w9)  erdat no-gap . c1 = c1 + w9.


ENDFORM.                    " f_write_detail
