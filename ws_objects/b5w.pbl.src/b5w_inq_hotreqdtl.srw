$PBExportHeader$b5w_inq_hotreqdtl.srw
$PBExportComments$[K.J.M] hotreqdtl 상세 조회
forward
global type b5w_inq_hotreqdtl from w_a_inq_m_m
end type
end forward

global type b5w_inq_hotreqdtl from w_a_inq_m_m
end type
global b5w_inq_hotreqdtl b5w_inq_hotreqdtl

on b5w_inq_hotreqdtl.create
call super::create
end on

on b5w_inq_hotreqdtl.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name : b5w_inq_hotreqdtl
	Desc.: hotreqdtl 상세내역
	Date : 2004.09.07
	Auth.: Kwon Jung Min
-------------------------------------------------------------------------*/

// default로 current에
dw_cond.object.gubun[1] = '0'

end event

event ue_ok();call super::ue_ok;String ls_trdt,	ls_payid,	ls_where,	ls_gubun
String ls_sqlstmt, ls_sql1, ls_sql2
Long ll_rows

dw_master.Reset()
dw_detail.Reset()
dw_cond.AcceptText()

ls_trdt = Trim(String(dw_cond.object.trdt[1],'yyyymmdd'))
ls_gubun = Trim(dw_cond.object.gubun[1])
ls_payid = Trim(dw_cond.object.payid[1])

IF IsNull(ls_trdt) THEN ls_trdt = ""
IF IsNull(ls_gubun) THEN ls_gubun = ""
IF IsNull(ls_payid) THEN ls_payid = ""

// 필수 입력 사항 check
IF ls_trdt = "" THEN
	f_msg_info(200, title, "청구기준일")
	dw_cond.SetFocus()
	dw_cond.SetColumn("trdt")
	Return	
END IF

//Dynamic SQL
ls_where = ""
ls_sql1 = ""
ls_sql1 = ""

// gubun = 0 --> Current, 1 --> History
IF ls_gubun="0" Then
	ls_sql1 = " SELECT A.REQNUM, A.PAYID, A.TRDT, SUM(A.TRAMT)  TRAMT " + &
             " FROM HOTREQDTL A, TRCODE  B " + &
			    " WHERE (A.TRCOD = B.TRCOD ) " + &
			    " AND  A.TRCOD IS NOT NULL " + &
			    " AND B.IN_YN = 'N' AND "
  				
ELSE
	ls_sql1 = " SELECT A.REQNUM, A.PAYID, A.TRDT, SUM(A.TRAMT)  TRAMT " + &
             " FROM HOTREQDTLH A, TRCODE  B " + &
			    " WHERE (A.TRCOD = B.TRCOD ) " + &
			    " AND  A.TRCOD IS NOT NULL " + &
			    " AND B.IN_YN = 'N' AND "
END IF

ls_sql2 = " GROUP BY A.REQNUM, A.PAYID, A.TRDT "				  

If ls_trdt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where	+= "TO_CHAR(A.TRDT,'YYYYMMDD') = '"+ ls_trdt +"' "
End If

If ls_payid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where	+= "PAYID = '"+ ls_payid +"' "
End If

ls_sqlstmt = ls_sql1 + ls_where + ls_sql2
dw_master.SetSQLSelect(ls_sqlstmt)

dw_master.SetTransObject(SQLCA)
ll_rows = dw_master.Retrieve()


If ( ll_rows = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_rows < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

type dw_cond from w_a_inq_m_m`dw_cond within b5w_inq_hotreqdtl
integer width = 1568
integer height = 184
string dataobject = "b5d_cnd_inq_hotreqdtl"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;idwo_help_col[1] = Object.payid
is_help_win[1] = "b5w_hlp_paymst"
is_data[1] = "CloseWithReturn"

end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			Object.payid[row]      = iu_cust_help.is_data2[1]
			Object.paynm[row] = iu_cust_help.is_data2[2]
		End If
End Choose

AcceptText()

Return 0 
end event

event dw_cond::itemchanged;call super::itemchanged;//Item Change Event
String ls_customernm
String ls_gubun

Choose Case dwo.name
	Case "payid"
		
		If data <> "" then 
			SELECT CUSTOMERNM
			  INTO :ls_customernm
			  FROM CUSTOMERM
			 WHERE CUSTOMERID = :data ;
			 
			If SQLCA.SQLCode < 0 Then
				f_msg_info(9000, title, 'select error')
				Return -1
			ElseIf SQLCA.SQLCode = 100 Then
				f_msg_info(9000, title, 'select not found')
			Else
				This.object.paynm[1] = ls_customernm
			End If
		Else
			This.object.paynm[1] = ""
			
		End If		 
		 
End Choose

Return 0 
end event

type p_ok from w_a_inq_m_m`p_ok within b5w_inq_hotreqdtl
integer x = 1687
end type

type p_close from w_a_inq_m_m`p_close within b5w_inq_hotreqdtl
integer x = 1989
end type

type gb_cond from w_a_inq_m_m`gb_cond within b5w_inq_hotreqdtl
integer width = 1614
integer height = 260
end type

type dw_master from w_a_inq_m_m`dw_master within b5w_inq_hotreqdtl
integer y = 280
string dataobject = "b5d_inq_hotreqdtl"
end type

event dw_master::ue_init();call super::ue_init;dwObject ldwo_sort
ldwo_sort = Object.reqnum_t
uf_init(ldwo_sort)

end event

type dw_detail from w_a_inq_m_m`dw_detail within b5w_inq_hotreqdtl
integer y = 732
string dataobject = "b5dw_inq_detail_hotreqdtl"
end type

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//String	ls_where
Long		ll_rows , ll_masterrow
String	ls_reqnum,	ls_gubun
//
dw_master.AcceptText()

IF dw_master.RowCount() < 1 THEN RETURN -1

ll_masterrow = dw_master.GetSelectedrow(0)

ls_reqnum = Trim(String(dw_master.Object.reqnum[ll_masterrow]))
ls_gubun = Trim(dw_cond.object.gubun[1])

//Retrieve
If ll_masterrow > 0 Then
	IF ls_gubun = '0' THEN // current
		This.DataObject = "b5dw_inq_detail_hotreqdtl"
		This.SetTransObject(SQLCA)
		ll_rows = This.Retrieve(ls_reqnum)
	ELSE	// history
		This.DataObject = "b5dw_inq_detail_hotreqdtlh"
		This.SetTransObject(SQLCA)
		ll_rows = This.Retrieve(ls_reqnum)
	END IF
	If ll_rows < 0 Then
		f_msg_usr_err(2100, Parent.Title, "Retrieve()")
		Return -1
	ElseIf ll_rows = 0 Then
		Return 1
	End If
End if

Return 0
end event

type st_horizontal from w_a_inq_m_m`st_horizontal within b5w_inq_hotreqdtl
integer y = 692
end type

