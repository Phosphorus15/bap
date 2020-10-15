open Bap_core_theory
open Base
open KB.Syntax

open Thumb_core

type eff = unit Theory.effect KB.t

module Make(CT : Theory.Core) = struct
  module T = Thumb_core.Make(CT)
  open T open T.Syntax

  let unsigned x = CT.unsigned s32 x
  let signed x = CT.signed s32 x
  let half x = CT.low s16 x
  let byte x  = CT.low s8 x
  let var = CT.var

  (**************************************************************)

  let ldri rd r i = data [
      rd := load s32 (var r + const i)
    ]

  let ldrr rd rn rm = data [
      rd := load s32 (var rn + var rm);
    ]

  let ldrbi rd rn i = data [
      rd := unsigned @@ load s8 (var rn + const i)
    ]

  let ldrbr rd rn rm = data [
      rd := unsigned @@ load s8 (var rn + var rm)
    ]

  let ldrsb rd rn rm = data [
      rd := signed @@ load s8 (var rn + var rm)
    ]

  let ldrhi rd rn i = data [
      rd := unsigned @@ load s16 (var rn + const i)
    ]

  let ldrhr rd rn rm = data [
      rd := unsigned @@ load s16 (var rn + var rm)
    ]

  let ldrsh rd rn rm = data [
      rd := signed @@ load s16 (var rn + var rm);
    ]

  let ldrpci rd pc off = data [
      rd := load s32 @@ bitv pc + const off;
    ]

  let ldm b regs = data [
      foreach regs @@ fun r -> [
        r := load s32 @@ var b;
        b += const 4;
      ]
    ]

  let stri rd rm i = data [
      var rd <-- var rm + const i
    ]

  let strr rd rm rn = data [
      var rd <-- var rm + var rn
    ]

  let strhi rd rm i = data [
      var rd <-- half (var rm + const i);
    ]

  let strhr rd rm rn = data [
      var rd <-- half (var rm + var rn);
    ]

  let strbi rd rm i = data [
      var rd <-- byte (var rm + const i);
    ]

  let strbr rd rm rn = data [
      var rd <-- byte (var rm + var rn)
    ]

  let stm i regs = data [
      foreach regs @@ fun r -> [
        var i <-- var r;
        i += const 4;
      ]
    ]

  let pop regs = ldm sp regs

  let popret regs =
    let data = foreach regs @@ fun r -> [
        r := load s32 @@ var sp;
        sp += const 4;
      ] in
    let ctrl = CT.jmp (load s32 (var sp)) in
    label >>= fun lbl ->
    CT.blk lbl data ctrl

  let push regs = data [
      sp -= const Int.(List.length regs * 4);
      foreachi regs @@ fun i r -> [
        var sp + const Int.(i*4) <-- var r;
      ]
    ]

end