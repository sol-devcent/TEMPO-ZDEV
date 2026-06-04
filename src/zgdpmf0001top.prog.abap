*----------------------------------------------------------------------*
*   INCLUDE ZGDPMF0001TOP                                              *
*----------------------------------------------------------------------*
TABLES: mbew.
*  caufvd,riwo1,iloa.

DATA: BEGIN OF d_caufv.
        INCLUDE STRUCTURE caufv.
DATA: END OF d_caufv.

DATA: BEGIN OF d_viqmel.
        INCLUDE STRUCTURE viqmel.
DATA: END OF d_viqmel.

DATA: BEGIN OF d_qmfe.
        INCLUDE STRUCTURE qmfe.
DATA: END OF d_qmfe.

DATA: BEGIN OF d_afvc.
        INCLUDE STRUCTURE afvc.
DATA: END OF d_afvc.

DATA: BEGIN OF d_afvv .
        INCLUDE STRUCTURE afvv.
DATA: END OF d_afvv.

DATA: BEGIN OF t_resb OCCURS 1.
        INCLUDE STRUCTURE resb.
DATA: END OF t_resb.

DATA: wa_resb LIKE resbd.

DATA: c_form(30).
*CONSTANTS c_form(30) VALUE 'ZGDPMF0001_01'.
DATA  d_sort_date.

INCLUDE liprtd01.
*DATA  device.
INCLUDE liprtf04.

*DATA  op_print_tab TYPE t_op_print_tab WITH HEADER LINE.
DATA  kbedp_tab    TYPE t_kbedp_tab WITH HEADER LINE.
*DATA  ihpad_tab    TYPE t_ihpad_tab WITH HEADER LINE.
DATA  ihsg_tab     TYPE t_ihsg_tab  WITH HEADER LINE.
DATA  ihgns_tab    TYPE t_ihgns_tab WITH HEADER LINE.
DATA  iafvgd       TYPE t_afvgd WITH HEADER LINE.
DATA  wa_afvgd     TYPE t_afvgd.
DATA  iripw0       TYPE t_ripw0 WITH HEADER LINE.
DATA  iresbd       TYPE t_resbd WITH HEADER LINE.
DATA  iaffhd       TYPE t_affhd WITH HEADER LINE.
DATA  device         LIKE itcpp-tddevice.
DATA  print_language LIKE  t390_u-print_lang.
DATA t_line LIKE tline OCCURS 1 WITH HEADER LINE.

TYPES: BEGIN OF ta_afru,
         aufnr   LIKE afru-aufnr,
         isdd    LIKE afru-isdd,
         isdz    LIKE afru-isdz,
         iedd    LIKE afru-iedd,
         iedz    LIKE afru-iedz,
       END OF ta_afru.

DATA: i_afru  TYPE ta_afru OCCURS 0,
      wa_afru TYPE ta_afru.

TYPES: BEGIN OF ta_line,
         aufpl  LIKE afvc-aufpl,
         aplzl  LIKE afvc-aplzl,
         tdline LIKE tline-tdline,
       END OF ta_line.

DATA: i_line  TYPE ta_line OCCURS 0,
      wa_line TYPE ta_line.

*  TABLES: *nast,
*          nast,
*          tnapr,
*          mkpf,
*          mseg,
*          lfa1,
*          ekko,
*          t001w,
*          mara,
*          usr21,
*          adrp,
*          mbew,
*          rkpf.
*
*  DATA: BEGIN OF t_nast_key,
*          mblnr LIKE mkpf-mblnr,
*          mjahr LIKE mkpf-mjahr,
*          zeile LIKE mseg-zeile,
*        END OF t_nast_key.
*
*  DATA  BEGIN OF t_mkpf OCCURS 1.
*          INCLUDE STRUCTURE mkpf.
*  DATA  END   OF t_mkpf.
*
*  DATA: BEGIN OF t_ekpo OCCURS 0.
*          INCLUDE STRUCTURE ekpo.
*  DATA: END OF t_ekpo.
*
*  DATA  BEGIN OF t_mseg OCCURS 1.
*          INCLUDE STRUCTURE mseg.
*  DATA  END   OF t_mseg.
*
*  DATA  d_retcode LIKE sy-subrc.
*  TABLES  komp.
*  TABLES: komk    ,
*          komvd   ,
*          vbco3   ,
*          vbdkr   ,
*          vbdpr   ,
*          vbdre   .
*
*  DATA: BEGIN OF tkomv OCCURS 50.
*          INCLUDE STRUCTURE komv.
*  DATA: END OF tkomv.
*
*  DATA: BEGIN OF t_konv OCCURS 50.
*          INCLUDE STRUCTURE konv.
*  DATA: END OF t_konv.
*
*  DATA: BEGIN OF tvbdpr OCCURS 100.      "Internal table for items
*          INCLUDE STRUCTURE vbdpr.
*  DATA: END OF tvbdpr.
*
*  DATA: BEGIN OF tkomvd OCCURS 50.
*          INCLUDE STRUCTURE komvd.
*  DATA: END OF tkomvd.
*
*  DATA: BEGIN OF *tkomvd OCCURS 50.
*          INCLUDE STRUCTURE komvd.
*  DATA: END OF *tkomvd.
*
*  DATA: BEGIN OF hkomv OCCURS 50.
*          INCLUDE STRUCTURE komv.
*  DATA: END OF hkomv.
*
*  DATA: BEGIN OF hkomvd OCCURS 50.
*          INCLUDE STRUCTURE komvd.
*  DATA: END OF hkomvd.
*
*  DATA: BEGIN OF tkomcon OCCURS 50.
*          INCLUDE STRUCTURE conf_out.
*  DATA: END   OF tkomcon.
*
*
*  DATA: xscreen(1) TYPE c.
