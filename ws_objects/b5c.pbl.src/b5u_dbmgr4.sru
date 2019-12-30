$PBExportHeader$b5u_dbmgr4.sru
$PBExportComments$[ceusee] DB 접근
forward
global type b5u_dbmgr4 from u_cust_a_db
end type
end forward

global type b5u_dbmgr4 from u_cust_a_db
end type
global b5u_dbmgr4 b5u_dbmgr4

forward prototypes
public subroutine uf_prc_db_01 ()
end prototypes

public subroutine uf_prc_db_01 ();String ls_trdt
String ls_fromdt
long ll_tr_customerid, ll_in_customerid, ll_b_customerid, i
Dec{2} ldc_tr_amt, ldc_in_amt, ldc_b_amt, ldc_totamt, ldc_rate, ldc_tr_overamt, ldc_tr_oversum
Real lr_rate
Date ld_trdt
ii_rc = -1
String ls_ref_desc, ls_temp, ls_result[]
Integer li_return
String ls_overamt_cod, ls_oversum_cod

ls_ref_desc = ""
ls_temp = fs_get_control("B5", "T108", ls_ref_desc)
If ls_temp = "" Then Return

li_return = fi_cut_string(ls_temp, ";", ls_result[])
If li_return <= 0 Then Return
ls_overamt_cod = ls_result[1]
ls_oversum_cod = ls_result[2]

Choose Case is_caller
	Case "b5w_prt_bilsum_trdt%ok"
//	lu_dbmgr.is_title = Title
//	lu_dbmgr.is_data[1] = ls_fromdt
//	lu_dbmgr.idw_data[1] = dw_list

ldc_totamt = 0
ls_fromdt = is_data[1]
//청구 기준일 보다 작은것의 미납액을 구한다.
 select nvl(sum(nvl(tramt, 0)), 0) tramt
 Into :ldc_totamt
 from reqdtl
 where to_char(trdt, 'yyyymm') < :ls_fromdt and (mark is null or mark <> 'D');


//1. 해당 TRDT구한다. 
  DECLARE cur_get_trdt CURSOR FOR
	SELECT distinct to_char(v1.trdt, 'yyyymm') trdt
	from (select trdt from reqdtl
			where to_char(trdt,'yyyymmdd') >= :ls_fromdt
	      union all
			select trdt from reqdtlh
			where to_char(trdt,'yyyymmdd') >= :ls_fromdt
			) v1
	order by trdt;

OPEN cur_get_trdt;

If SQLCA.sqlcode < 0 Then
	f_msg_sql_err(is_caller, ":CURSOR cur_get_trdt")
	Return
End If

Do While(True)
	FETCH cur_get_trdt
	INTO :ls_trdt;
			
	If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(is_caller, ":cur_get_trdt")
		CLOSE cur_get_trdt;
		Return 
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
	End If	   

   ld_trdt = Date( MidA(ls_trdt, 1, 4) + "-" + MidA(ls_trdt, 5, 2) + "-" + '01')

 select count(distinct v1.payid), sum(v1.tramt), sum(v1.payamt) * -1, sum(v1.overamt) overamt, sum(v1.oversum) oversum
 Into :ll_tr_customerid, :ldc_tr_amt, :ldc_in_amt, :ldc_tr_overamt, :ldc_tr_oversum
 from ( select req.payid, decode(tr.in_yn, 'Y', 0, nvl(req.tramt, 0)) tramt, 
               decode(tr.in_yn, 'Y',  nvl(req.tramt, 0),0) payamt,
               decode(tr.trcod, :ls_overamt_cod, nvl(req.tramt,0),0) overamt,
               decode(tr.trcod, :ls_oversum_cod, nvl(req.tramt,0),0) oversum
        from reqdtl req, trcode tr
        where  to_char(req.trdt, 'yyyymm') = :ls_trdt and (req.mark is null or req.mark <> 'D') and tr.trcod =req.trcod
        union all
        select req.payid, decode(tr.in_yn, 'Y', 0, nvl(req.tramt, 0)) tramt, 
               decode(tr.in_yn, 'Y',  nvl(req.tramt, 0),0) payamt,
               decode(tr.trcod, :ls_overamt_cod, nvl(req.tramt,0),0) overamt,
               decode(tr.trcod, :ls_oversum_cod, nvl(req.tramt,0),0) oversum
        from reqdtlh req, trcode tr
        where  to_char(req.trdt, 'yyyymm') = :ls_trdt and (req.mark is null or req.mark <> 'D') and tr.trcod=req.trcod ) v1;
 
  If SQLCA.sqlcode < 0 Then
	f_msg_sql_err(is_caller, "Select Error(REQDTL) # 1")
	Return
  ElseIf SQLCA.sqlcode  = 100 Then
	 ll_tr_customerid = 0
	 ldc_tr_amt = 0
	 ldc_in_amt = 0
  End If
 
 //미납고객수
 select count(v3.payid)
 Into :ll_b_customerid
 from (select payid, sum(tramt)
       from reqdtl
		 where to_char(trdt, 'yyyymm') = :ls_trdt and (mark is null or mark <> 'D')
		 group by payid
		 having sum(nvl(tramt, 0)) >0 ) v3;
 
  If SQLCA.sqlcode < 0 Then
	f_msg_sql_err(is_caller, "Select Error(REQDTL) # 2")
	Return
  ElseIf SQLCA.sqlcode  = 100 Then
	  ll_b_customerid = 0 
  End If
 //수납고객수 
  ll_in_customerid = ll_tr_customerid - ll_b_customerid
  
 //수납율
 If ldc_tr_amt <> 0 Then
   lr_rate = (ldc_in_amt / ldc_tr_amt)
Else
	ldc_rate = 0
end If
 
 //미납액
 select nvl(sum(nvl(tramt, 0)), 0) tramt
 Into :ldc_b_amt
 from reqdtl
 where to_char(trdt, 'yyyymm') = :ls_trdt and (mark is null or mark <> 'D');
 
 If SQLCA.sqlcode < 0 Then
	f_msg_sql_err(is_caller, "Select Error(REQDTL) # 3")
	Return
 ElseIf SQLCA.sqlcode  = 100 Then
	ldc_b_amt = 0 
 End If
 

  
 //Insert Row
 i = idw_data[1].InsertRow(0)
 ldc_totamt = ldc_totamt + ldc_b_amt
 idw_data[1].object.tr_customerid[i] = ll_tr_customerid
 idw_data[1].object.in_customerid[i] = ll_in_customerid
 idw_data[1].object.b_customerid[i] = ll_b_customerid
 idw_data[1].object.tr_amt[i] = ldc_tr_amt
 idw_data[1].object.in_amt[i] = ldc_in_amt
 idw_data[1].object.b_amt[i] = ldc_b_amt 
 idw_data[1].object.trdt[i] = ld_trdt
 idw_data[1].object.in_rate[i] = lr_rate
 idw_data[1].object.b_totamt[i] = ldc_totamt
 idw_data[1].object.tr_overamt[i] = ldc_tr_overamt
 idw_data[1].object.tr_oversum[i] = ldc_tr_oversum

Loop
CLOSE cur_get_trdt;

	  

   
End Choose

ii_rc = 0 
Return
end subroutine

on b5u_dbmgr4.create
call super::create
end on

on b5u_dbmgr4.destroy
call super::destroy
end on

