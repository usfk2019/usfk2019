$PBExportHeader$b5u_dbmgr5.sru
$PBExportComments$[chooys] DB 접근
forward
global type b5u_dbmgr5 from u_cust_a_db
end type
end forward

global type b5u_dbmgr5 from u_cust_a_db
end type
global b5u_dbmgr5 b5u_dbmgr5

forward prototypes
public subroutine uf_prc_db ()
public subroutine uf_prc_db_01 ()
end prototypes

public subroutine uf_prc_db ();String ls_trdt
String ls_location, ls_bef_location
long ll_tr_customerid, ll_in_customerid, ll_b_customerid, i
long ll_rows
Dec{2} ldc_tr_amt, ldc_in_amt, ldc_b_amt, ldc_totamt, ldc_rate
Real lr_rate
Dec{2} ld_rate
Date ld_trdt
DataWindow dw_list
ii_rc = -1


Choose Case is_caller
	Case "b5w_prt_bilsum_location%ok"
//	lu_dbmgr.is_title = Title
//	lu_dbmgr.is_data[1] = ls_trdt
//	lu_dbmgr.idw_data[1] = dw_list

ls_trdt = is_data[1]
dw_list = idw_data[1]

ll_rows = dw_list.RowCount()

FOR i=1 TO ll_rows

	ls_location = Trim(dw_list.object.location[i])
		
	 //청구고객수
	 select  count(v2.payid)
	 into :ll_tr_customerid
	from ( select  distinct req.payid
			 from   reqdtl req, customerm c
			where c.location = :ls_location  And  to_char(req.trdt,'yyyymm') = :ls_trdt 
					  And ( mark is null or mark <> 'D')  And  req.payid = c.customerid
			 Union all
			 Select  distinct req.payid
			  From   reqdtlh req, customerm c
			where c.location = :ls_location  And to_char(req.trdt,'yyyymm') = :ls_trdt
						And (mark is null or mark <> 'D') And req.payid = c.customerid) v2;
						
	  If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(is_caller, "Select Error(ll_tr_customerid)")
		Return
	  ElseIf SQLCA.sqlcode  = 100 Then
		  ll_b_customerid = 0 
	  End If
	 
	 //미납고객수
	 select count(v3.payid)
	 into :ll_b_customerid
	 from (select reqdtl.payid, sum(tramt)
			 from reqdtl, customerm c
			 where c.location = :ls_location
			 And reqdtl.payid = c.customerid
			 And  to_char(trdt, 'yyyymm') = :ls_trdt 
			 and (mark is null or mark <> 'D')
			 group by reqdtl.payid
			 having sum(nvl(tramt, 0)) >0 ) v3;
		 
 
  If SQLCA.sqlcode < 0 Then
	f_msg_sql_err(is_caller, "Select Error(ll_b_customerid)")
	Return
  ElseIf SQLCA.sqlcode  = 100 Then
	  ll_b_customerid = 0 
  End If
  
  
 //수납고객수 
  ll_in_customerid = ll_tr_customerid - ll_b_customerid
  
  ldc_tr_amt = dw_list.object.tramt[i]
  ldc_in_amt = dw_list.object.payamt[i]
 
	 //수납율
	If ldc_tr_amt <> 0 Then
		lr_rate = (ldc_in_amt / ldc_tr_amt)
	Else
		lr_rate = 0.00
	end If
 
  
 //Insert Row
 dw_list.object.trcnt[i] = ll_tr_customerid
 dw_list.object.paycnt[i] = ll_in_customerid
 dw_list.object.agcnt[i] = ll_b_customerid
 dw_list.object.payrate[i] = lr_rate

NEXT

	Case "b5w_prt_bilsum_location%ok_backup"
//	lu_dbmgr.is_title = Title
//	lu_dbmgr.is_data[1] = ls_trdt
//	lu_dbmgr.idw_data[1] = dw_list

//ls_trdt = is_data[1]
//
////1. 지역리스트를 추출한다.
//  DECLARE cur_get_location CURSOR FOR
//	select  v1.location, sum(v1.tramt),  sum(v1.payamt) * -1, sum(v1.agamt) 
//	from (  select  c.location, decode(tr.in_yn, 'Y', 0, nvl(req.tramt,0)) tramt, 
//	decode(tr.in_yn, 'Y', nvl(req.tramt,0),0) payamt,
//	nvl(req.tramt,0) agamt
//			  from   reqdtl req, trcode tr, customerm c
//			  where  to_char(req.trdt,'yyyymm') = :ls_trdt  And (req.mark is null  or  req.mark <> 'D' ) And  req.trcod = tr.trcod 
//						 And req.payid = c.customerid
//			  union  all
//			  select  c.location, decode(tr.in_yn, 'Y', 0, nvl(req.tramt,0)) tramt, 
//	decode(tr.in_yn, 'Y', nvl(req.tramt,0),0) payamt,
//	0  agamt
//			  from   reqdtlh req, trcode tr, customerm c
//	 where  to_char(req.trdt,'yyyymm') = :ls_trdt And (req.mark is null or req.mark <> 'D' ) And  req.trcod = tr.trcod 
//	And req.payid = c.customerid ) v1
//		Group by  v1.location;
//
//OPEN cur_get_location;
//
//If SQLCA.sqlcode < 0 Then
//	f_msg_sql_err(is_caller, ":CURSOR cur_get_location While Declare")
//	Return
//End If
//
//Do While(True)
//	FETCH cur_get_location
//	INTO :ls_location, :ldc_tr_amt, :ldc_in_amt, :ldc_b_amt;
//			
//	If SQLCA.sqlcode < 0 Then
//		f_msg_sql_err(is_caller, ":CURSOR cur_get_location While Fetch")
//		CLOSE cur_get_location;
//		Return 
//	ElseIf SQLCA.SQLCode = 100 Then
//		Exit
//	End If	   
//
//	
// //청구고객수
// select  count(v2.payid)
// into :ll_tr_customerid
//from ( select  distinct req.payid
//       from   reqdtl req, customerm c
//      where c.location = :ls_location  And  to_char(req.trdt,'yyyymm') = :ls_trdt 
//              And ( mark is null or mark <> 'D')  And  req.payid = c.customerid
//       Union all
//       Select  distinct req.payid
//        From   reqdtlh req, customerm c
//		where c.location = :ls_location  And to_char(req.trdt,'yyyymm') = :ls_trdt
//               And (mark is null or mark <> 'D') And req.payid = c.customerid) v2;
//					
//  If SQLCA.sqlcode < 0 Then
//	f_msg_sql_err(is_caller, "Select Error(ll_tr_customerid)")
//	CLOSE cur_get_location;
//	Return
//  ElseIf SQLCA.sqlcode  = 100 Then
//	  ll_b_customerid = 0 
//  End If
// 
// //미납고객수
// select count(v3.payid)
// into :ll_b_customerid
// from (select reqdtl.payid, sum(tramt)
//       from reqdtl, customerm c
//		 where c.location = :ls_location
//		 And reqdtl.payid = c.customerid
//		 And  to_char(trdt, 'yyyymm') = :ls_trdt 
//		 and (mark is null or mark <> 'D')
//		 group by reqdtl.payid
//		 having sum(nvl(tramt, 0)) >0 ) v3;
//		 
// 
//  If SQLCA.sqlcode < 0 Then
//	f_msg_sql_err(is_caller, "Select Error(ll_b_customerid)")
//	CLOSE cur_get_location;
//	Return
//  ElseIf SQLCA.sqlcode  = 100 Then
//	  ll_b_customerid = 0 
//  End If
//  
//  
// //수납고객수 
//  ll_in_customerid = ll_tr_customerid - ll_b_customerid
//  
//  
// //수납율
// If ldc_tr_amt <> 0 Then
//   ldc_rate = (ldc_in_amt / ldc_tr_amt)
//Else
//	ldc_rate = 0
//end If
// 
//  
// //Insert Row
// i = idw_data[1].InsertRow(0)
// ldc_totamt = ldc_totamt + ldc_b_amt
// idw_data[1].object.location[i] = ls_location
// idw_data[1].object.tr_customerid[i] = ll_tr_customerid
// idw_data[1].object.in_customerid[i] = ll_in_customerid
// idw_data[1].object.b_customerid[i] = ll_b_customerid
// idw_data[1].object.tr_amt[i] = ldc_tr_amt
// idw_data[1].object.in_amt[i] = ldc_in_amt
// idw_data[1].object.b_amt[i] = ldc_b_amt 
// idw_data[1].object.in_rate[i] = ldc_rate
// idw_data[1].object.b_totamt[i] = ldc_totamt
//
//Loop
//
//CLOSE cur_get_location;

End Choose

ii_rc = 0 
Return
end subroutine

public subroutine uf_prc_db_01 ();String ls_trdt
String ls_paymethod
long ll_tr_customerid, ll_in_customerid, ll_b_customerid, i
long ll_rows
Dec{2} ldc_tr_amt, ldc_in_amt, ldc_b_amt, ldc_totamt, ldc_rate
Real lr_rate
Date ld_trdt
DataWindow dw_list
ii_rc = -1

Choose Case is_caller
	Case "b5w_prt_bilsum_paymethod%ok"
//	lu_dbmgr.is_title = Title
//	lu_dbmgr.is_data[1] = ls_trdt
//	lu_dbmgr.idw_data[1] = dw_list

ls_trdt = is_data[1]
dw_list = idw_data[1]

ll_rows = dw_list.RowCount()

FOR i=1 TO ll_rows

	ls_paymethod = Trim(dw_list.object.pay_method[i])
	ldc_in_amt = dw_list.object.payamt[i]
	ldc_tr_amt = dw_list.object.tramt[i]
		
	 //청구고객수
	 select  count(v2.payid)
	 into :ll_tr_customerid
	from ( select  distinct req.payid
			 from   reqdtl req, billinginfo c
			where c.pay_method = :ls_paymethod  And  to_char(req.trdt,'yyyymm') = :ls_trdt 
					  And ( mark is null or mark <> 'D')  And  req.payid = c.customerid
			 Union all
			 Select  distinct req.payid
			  From   reqdtlh req, billinginfo c
			where c.pay_method = :ls_paymethod  And to_char(req.trdt,'yyyymm') = :ls_trdt
						And (mark is null or mark <> 'D') And req.payid = c.customerid) v2;
						
	  If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(is_caller, "Select Error(ll_tr_customerid)")
		Return
	  ElseIf SQLCA.sqlcode  = 100 Then
		  ll_b_customerid = 0 
	  End If
	 
	 //미납고객수
	 select count(v3.payid)
	 into :ll_b_customerid
	 from (select reqdtl.payid, sum(tramt)
			 from reqdtl, billinginfo c
			 where c.pay_method = :ls_paymethod
			 And reqdtl.payid = c.customerid
			 And  to_char(trdt, 'yyyymm') = :ls_trdt 
			 and (mark is null or mark <> 'D')
			 group by reqdtl.payid
			 having sum(nvl(tramt, 0)) >0 ) v3;
		 
 
  If SQLCA.sqlcode < 0 Then
	f_msg_sql_err(is_caller, "Select Error(ll_b_customerid)")
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
		lr_rate = 0
	end If
 
  
 //Insert Row
 dw_list.object.trcnt[i] = ll_tr_customerid
 dw_list.object.paycnt[i] = ll_in_customerid
 dw_list.object.agcnt[i] = ll_b_customerid
 dw_list.object.payrate[i] = lr_rate

NEXT

	Case "b5w_prt_bilsum_location%ok_backup"
//	lu_dbmgr.is_title = Title
//	lu_dbmgr.is_data[1] = ls_trdt
//	lu_dbmgr.idw_data[1] = dw_list

//ls_trdt = is_data[1]
//
////1. 지역리스트를 추출한다.
//  DECLARE cur_get_location CURSOR FOR
//	select  v1.location, sum(v1.tramt),  sum(v1.payamt) * -1, sum(v1.agamt) 
//	from (  select  c.location, decode(tr.in_yn, 'Y', 0, nvl(req.tramt,0)) tramt, 
//	decode(tr.in_yn, 'Y', nvl(req.tramt,0),0) payamt,
//	nvl(req.tramt,0) agamt
//			  from   reqdtl req, trcode tr, customerm c
//			  where  to_char(req.trdt,'yyyymm') = :ls_trdt  And (req.mark is null  or  req.mark <> 'D' ) And  req.trcod = tr.trcod 
//						 And req.payid = c.customerid
//			  union  all
//			  select  c.location, decode(tr.in_yn, 'Y', 0, nvl(req.tramt,0)) tramt, 
//	decode(tr.in_yn, 'Y', nvl(req.tramt,0),0) payamt,
//	0  agamt
//			  from   reqdtlh req, trcode tr, customerm c
//	 where  to_char(req.trdt,'yyyymm') = :ls_trdt And (req.mark is null or req.mark <> 'D' ) And  req.trcod = tr.trcod 
//	And req.payid = c.customerid ) v1
//		Group by  v1.location;
//
//OPEN cur_get_location;
//
//If SQLCA.sqlcode < 0 Then
//	f_msg_sql_err(is_caller, ":CURSOR cur_get_location While Declare")
//	Return
//End If
//
//Do While(True)
//	FETCH cur_get_location
//	INTO :ls_location, :ldc_tr_amt, :ldc_in_amt, :ldc_b_amt;
//			
//	If SQLCA.sqlcode < 0 Then
//		f_msg_sql_err(is_caller, ":CURSOR cur_get_location While Fetch")
//		CLOSE cur_get_location;
//		Return 
//	ElseIf SQLCA.SQLCode = 100 Then
//		Exit
//	End If	   
//
//	
// //청구고객수
// select  count(v2.payid)
// into :ll_tr_customerid
//from ( select  distinct req.payid
//       from   reqdtl req, customerm c
//      where c.location = :ls_location  And  to_char(req.trdt,'yyyymm') = :ls_trdt 
//              And ( mark is null or mark <> 'D')  And  req.payid = c.customerid
//       Union all
//       Select  distinct req.payid
//        From   reqdtlh req, customerm c
//		where c.location = :ls_location  And to_char(req.trdt,'yyyymm') = :ls_trdt
//               And (mark is null or mark <> 'D') And req.payid = c.customerid) v2;
//					
//  If SQLCA.sqlcode < 0 Then
//	f_msg_sql_err(is_caller, "Select Error(ll_tr_customerid)")
//	CLOSE cur_get_location;
//	Return
//  ElseIf SQLCA.sqlcode  = 100 Then
//	  ll_b_customerid = 0 
//  End If
// 
// //미납고객수
// select count(v3.payid)
// into :ll_b_customerid
// from (select reqdtl.payid, sum(tramt)
//       from reqdtl, customerm c
//		 where c.location = :ls_location
//		 And reqdtl.payid = c.customerid
//		 And  to_char(trdt, 'yyyymm') = :ls_trdt 
//		 and (mark is null or mark <> 'D')
//		 group by reqdtl.payid
//		 having sum(nvl(tramt, 0)) >0 ) v3;
//		 
// 
//  If SQLCA.sqlcode < 0 Then
//	f_msg_sql_err(is_caller, "Select Error(ll_b_customerid)")
//	CLOSE cur_get_location;
//	Return
//  ElseIf SQLCA.sqlcode  = 100 Then
//	  ll_b_customerid = 0 
//  End If
//  
//  
// //수납고객수 
//  ll_in_customerid = ll_tr_customerid - ll_b_customerid
//  
//  
// //수납율
// If ldc_tr_amt <> 0 Then
//   ldc_rate = (ldc_in_amt / ldc_tr_amt)
//Else
//	ldc_rate = 0
//end If
// 
//  
// //Insert Row
// i = idw_data[1].InsertRow(0)
// ldc_totamt = ldc_totamt + ldc_b_amt
// idw_data[1].object.location[i] = ls_location
// idw_data[1].object.tr_customerid[i] = ll_tr_customerid
// idw_data[1].object.in_customerid[i] = ll_in_customerid
// idw_data[1].object.b_customerid[i] = ll_b_customerid
// idw_data[1].object.tr_amt[i] = ldc_tr_amt
// idw_data[1].object.in_amt[i] = ldc_in_amt
// idw_data[1].object.b_amt[i] = ldc_b_amt 
// idw_data[1].object.in_rate[i] = ldc_rate
// idw_data[1].object.b_totamt[i] = ldc_totamt
//
//Loop
//
//CLOSE cur_get_location;

End Choose

ii_rc = 0 
Return
end subroutine

on b5u_dbmgr5.create
call super::create
end on

on b5u_dbmgr5.destroy
call super::destroy
end on

