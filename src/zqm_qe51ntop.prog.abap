*----------------------------------------------------------------------*
*   INCLUDE ZQM_QE51NTOP
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES : sscrfields, qals, qasr.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA : gv_maktx       TYPE maktx,
       gv_rec         TYPE i,
       gv_katalgart1  TYPE qkatausw.

DATA : gw_dyn_fcat      TYPE lvc_s_fcat,
       gt_dyn_fcat      TYPE lvc_t_fcat,
       gt_dyn_table     TYPE REF TO data,
       gw_line          TYPE REF TO data,
       gt_alv_fieldcat  TYPE slis_t_fieldcat_alv,
       gw_alv_fieldcat  TYPE slis_fieldcat_alv.

DATA : gt_list_top_of_page TYPE slis_t_listheader.

DATA : gv_headl1(100),
       gv_headl2(100),
       gv_headl3(100),
       gv_headl4(100).

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA : BEGIN OF gt_qals OCCURS 0,
         prueflos   TYPE qplos,
         matnr      TYPE matnr,
         charg      TYPE charg_d,
         objnr      TYPE j_objnr,
         plnty      TYPE plnty,
         plnnr      TYPE plnnr,
         plnal      TYPE plnal,
         aufpl      TYPE co_aufpl,
       END OF gt_qals.

DATA : gt_plmk  LIKE plmk OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF gt_plpo OCCURS 0,
         plnty      TYPE plnty,
         plnnr      TYPE plnnr,
         plnkn      TYPE plnkn,
         zaehl      TYPE cim_count,
         vornr      TYPE vornr,
         steus      TYPE steus,
         phflg      TYPE phflg,
         ltxa1      TYPE ltxa1,
       END OF gt_plpo.

DATA : BEGIN OF gt_sample OCCURS 0,
         insplot    TYPE qibplosnr,
         inspoper	  TYPE qibpvornr,
         inspchar	  TYPE qibpmerknr,
         inspsample	TYPE qibpprobe,
         mean_value	TYPE qmean_val,
       END OF gt_sample.

DATA : gt_qase  TYPE STANDARD TABLE OF qase INITIAL SIZE 0.

DATA : BEGIN OF gt_qasr OCCURS 0,
         prueflos	       TYPE qplos,
         vorglfnr	       TYPE qlfnkn,
         merknr	         TYPE qmerknrp,
         probenr         TYPE qstipronr,
         katalgart1	     TYPE qkatausw,
         gruppe1         TYPE qcodegrp,
         code1           TYPE qcode,
         original_input  TYPE qoriginal_input,
       END OF gt_qasr.

DATA : BEGIN OF gt_qamr OCCURS 0,
         prueflos	    TYPE qplos,
         vorglfnr	    TYPE qlfnkn,
         merknr	      TYPE qmerknrp,
         mittelwert	  TYPE qmittelwrt,
       END OF gt_qamr.

DATA : BEGIN OF gt_qpct OCCURS 0,
         katalogart	  TYPE qkatart,
         codegruppe	  TYPE qcodegrp,
         code	        TYPE qcode,
         kurztext	    TYPE qtxt_code,
       END OF gt_qpct.

DATA : BEGIN OF gt_qamv OCCURS 0,
         prueflos	        TYPE qplos,
         vorglfnr	        TYPE qlfnkn,
         merknr	          TYPE qmerknrp,
         kurztext	        TYPE qmkkurztxt,
       END OF gt_qamv.

FIELD-SYMBOLS : <fs_itab>    TYPE STANDARD TABLE,
                <fs_wa>      TYPE ANY,
                <fs_field>   TYPE ANY.

DATA : BEGIN OF gt_out OCCURS 0,
         matnr   TYPE matnr,
       END OF gt_out.
