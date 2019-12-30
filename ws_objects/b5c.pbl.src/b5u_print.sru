$PBExportHeader$b5u_print.sru
$PBExportComments$[backgu-2002/09/24]
forward
global type b5u_print from u_cust_a_db
end type
end forward

global type b5u_print from u_cust_a_db
end type
global b5u_print b5u_print

type prototypes

end prototypes

type variables

end variables

forward prototypes
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db ();Long		ll_rows, ll_row, ll_insrow
String	ls_column

Integer	li_milseq, li_bilseq
String	ls_payid, ls_bilcodnm, ls_reqnum, ls_trdt
Dec{2}	ld_amtsum
Dec{2}	ld_amt01, ld_amt02, ld_amt03, ld_amt04, ld_amt05 &
       , ld_amt06, ld_amt07, ld_amt08, ld_amt09, ld_amt10 &
		 , ld_amt11, ld_amt12, ld_amt13, ld_amt14, ld_amt15 &
		 , ld_amt16, ld_amt17, ld_amt18, ld_amt19, ld_amt20 &
		 , ld_amt21, ld_amt22, ld_amt23, ld_amt24, ld_amt25 &
		 , ld_amt26, ld_amt27, ld_amt28, ld_amt29, ld_amt30

ii_rc = -1

Choose Case is_caller
	Case "b5w_inq_reqdtl_paymst%retrieve"
		// 2001.08.21 , T&C Technology , Oh Chung Hwan		
		ls_payid = is_data[1]
		idw_data[1].Reset()

		//Name Setting
		idw_data[1].Object.t_marknm.Text = "[" + ls_payid + "] " + is_data[2]

		//Amount Setting
      DECLARE cur_read_reqinfo CURSOR FOR
      SELECT to_char(a.trdt, 'yyyymmdd'), a.reqnum, a.btramt01, a.btramt02, a.btramt03, a.btramt04,
		       a.btramt05, a.btramt06, a.btramt07, a.btramt08, a.btramt09, a.btramt10, a.btramt11, 
				 a.btramt12, a.btramt13, a.btramt14, a.btramt15, a.btramt16, a.btramt17, a.btramt18, 
				 a.btramt19, a.btramt20, a.btramt21, a.btramt22, a.btramt23, a.btramt24, a.btramt25, 
				 a.btramt26, a.btramt27, a.btramt28, a.btramt29, a.btramt30
      FROM  reqinfo a
      WHERE a.payid = :ls_payid
		 AND  a.seq = ( SELECT MAX(seq) FROM reqinfo WHERE payid = :ls_payid AND trdt = a.trdt );
				
		OPEN cur_read_reqinfo;
		Do While True
			FETCH cur_read_reqinfo
			INTO :ls_trdt, :ls_reqnum, :ld_amt01, :ld_amt02, :ld_amt03, :ld_amt04, :ld_amt05,
			     :ld_amt06, :ld_amt07, :ld_amt08, :ld_amt09, :ld_amt10, :ld_amt11, :ld_amt12,
				  :ld_amt13, :ld_amt14, :ld_amt15, :ld_amt16, :ld_amt17, :ld_amt18, :ld_amt19,
				  :ld_amt20, :ld_amt21, :ld_amt22, :ld_amt23, :ld_amt24, :ld_amt25, :ld_amt26,
  				  :ld_amt27, :ld_amt28, :ld_amt29, :ld_amt30;

			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " : cur_read_reqinfo")
				Close cur_read_reqinfo;
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If

			ll_insrow = idw_data[1].InsertRow(0)
			idw_data[1].Object.trdt[ll_insrow] = ls_trdt
			idw_data[1].Object.reqnum[ll_insrow] = ls_reqnum

			DECLARE cur_read_trprtd CURSOR FOR
			SELECT milseq
			FROM   trprtc
			GROUP BY milseq;
			
         li_bilseq = 0
			OPEN cur_read_trprtd;
			Do While True
				FETCH cur_read_trprtd
				INTO :li_milseq;
	
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " : cur_read_trprtd")
					Close cur_read_trprtd;
					Return
				ElseIf SQLCA.SQLCode = 100 Then
					Exit
				End If

				Choose Case li_milseq
					Case 1
						ld_amtsum = ld_amt01
					case 2
						ld_amtsum = ld_amt02
					Case 3
						ld_amtsum = ld_amt03
					case 4
						ld_amtsum = ld_amt04
					Case 5
						ld_amtsum = ld_amt05
					case 6
						ld_amtsum = ld_amt06
					Case 7
						ld_amtsum = ld_amt07
					case 8
						ld_amtsum = ld_amt08
					Case 9
						ld_amtsum = ld_amt09
					case 10
						ld_amtsum = ld_amt10
					Case 11
						ld_amtsum = ld_amt11
					case 12
						ld_amtsum = ld_amt12
					Case 13
						ld_amtsum = ld_amt13
					case 14
						ld_amtsum = ld_amt14
					Case 15
						ld_amtsum = ld_amt15
					case 16
						ld_amtsum = ld_amt16
					Case 17
						ld_amtsum = ld_amt17
					case 18
						ld_amtsum = ld_amt18
					Case 19
						ld_amtsum = ld_amt19
					case 20
						ld_amtsum = ld_amt20
					Case 21
						ld_amtsum = ld_amt21
					case 22
						ld_amtsum = ld_amt22
					Case 23
						ld_amtsum = ld_amt23
					case 24
						ld_amtsum = ld_amt24
					Case 25
						ld_amtsum = ld_amt25
					case 26
						ld_amtsum = ld_amt26
					Case 27
						ld_amtsum = ld_amt27
					case 28
						ld_amtsum = ld_amt28
					Case 29
						ld_amtsum = ld_amt29
					case 30
						ld_amtsum = ld_amt30
				End Choose

				li_bilseq++
				ls_column = "amt_" + String(li_bilseq)
				If IsNull(ld_amtsum) Then ld_amtsum = 0
				idw_data[1].SetItem(ll_insrow, ls_column, ld_amtsum)
			Loop
			Close cur_read_trprtd;
		Loop
		Close cur_read_reqinfo;

	Case Else
		f_msg_info_app(9000, "uf_prc_db_app.uf_prc_db()", "Matching statement Not found.(" + String(is_caller) + ")")
End Choose

ii_rc = 0

end subroutine

on b5u_print.create
call super::create
end on

on b5u_print.destroy
call super::destroy
end on

