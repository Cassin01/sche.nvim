(local M {})

(fn M.epi [i v source ...]
  "each ipairs"
  `(each [,i ,v (ipairs ,source)]
    ,...))

(fn M.when-let [res cond ...]
  `(let [,res ,cond]
       (when (not= ,res nil) ,...)))

;;; autocmd
(fn _group_handler [group]
  `(if 
     (= (type ,group) :string)
     (vim.api.nvim_create_augroup ,group {:clear true})
     (= (type ,group) :number)
     ,group
     (print "au: group must be number or string" ,group)))

(fn _callback [group event body ?opt]
  `(let [opt# {:callback (λ [] ,body)
               :group ,(_group_handler group)}]
     (each [k# v# (pairs (or ,?opt {}))]
       (tset opt# k# v#))
     (vim.api.nvim_create_autocmd ,event opt#)))

(fn _command [group event command ?opt]
  `(let [opt# {:command ,command
               :group ,(_group_handler group)}]
     (each [k# v# (pairs (or ,?opt {}))]
       (tset opt# k# v#))
     (vim.api.nvim_create_autocmd ,event opt#)))

(fn M.au! [group event body ?opt]
  (if
    (= (type body) :table) (_callback group event body ?opt)
    (= (type body) :string) (_command group event body ?opt)
    (assert-compile false "au: body must be a sequence or string" body)))

(fn M.async-do! [body]
  `(do
     (var async# nil)
     (set async#
          (vim.loop.new_async
            (vim.schedule_wrap
                  (λ []
                    ,body
                    (async#:close)))))
     (async#:send)))

M
