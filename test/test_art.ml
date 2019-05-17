open OUnit2

let rec _read_lines res inf = 
  let line = try (Some (input_line inf)) with End_of_file -> None in 
  match line with 
  | None -> res 
  | Some(v) -> _read_lines (v :: res) inf

let read_lines inf = _read_lines [] inf

let words = 
  let inf = open_in "/usr/share/dict/words" in 
  let lines = read_lines inf in 
  close_in inf;
  lines

let test_words _ = 
  let tree = Art.create () in 
  let n_words = List.fold_left (fun ctr word -> 
    Art.put tree word ctr; ctr + 1
  ) 1 words in 
  let n_words = n_words - 1 in 
  let _ = assert_equal n_words (Art.length tree) in
  let _, target_sum = List.fold_left (fun (ctr, sum) _ -> ((ctr + 1), (sum + ctr))) (1, 1) words in 
  let target_sum = target_sum - 1 in
  let sum = (Art.sum tree) in
  let _ = assert_equal sum target_sum in
  let _n_words = List.fold_left (fun ctr word -> 
    let v = Art.get tree word in 
    assert_equal (ctr - v) 0; ctr + 1
  ) 1 words in
  List.iter (fun word -> Art.update tree word ((+) 1)) words;
  let _ = List.fold_left (fun ctr word -> 
    assert_equal ctr (Art.get tree word); ctr + 1
  ) 2 words in ()

let rec take n lst = 
  if n > 0 then ((List.hd lst) :: take (n - 1) (List.tl lst)) else []

let test_items _ = 
  let tree = Art.create () in
  (*let words = take 10000 words in*)
  let target = Hashtbl.create (List.length words) in 
  List.iter (fun word -> 
    Art.put tree word 1;
    Hashtbl.add target word 1;
  ) words;
  for _ = 0 to 150 do
    (let items = Art.items tree in
    List.iter (fun (k, c) -> 
      assert_equal (Hashtbl.find target k) c;
    ) items;)
  done

let suite = "suite" >::: [
    "test_words" >:: test_words;
    "test_items" >:: test_items;
  ]


let () = run_test_tt_main suite