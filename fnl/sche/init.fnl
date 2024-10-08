;;; Util

;; Macros

(import-macros {: epi : when-let : au! : async-do! } :lua.sche.macros)

;; Functions

(fn bmap [bufnr mode key cmd desc]
  (if (= (type cmd) :string)
    (vim.api.nvim_buf_set_keymap bufnr mode key cmd {:noremap true :silent true :desc desc})
    (vim.api.nvim_buf_set_keymap bufnr mode key "" {:callback cmd :noremap true :silent true :desc desc})))

(fn _cons [x ...]
  [x  ...])
(fn _pull [x xs]
  "use as cons"
  (_cons x (unpack xs)))
(fn _unfold-iter [seed ?object ?finish]
  (let [v (seed)]
    (if (= nil v)
      (do
        (when (and (not= ?finish nil) (not= ?object nil))
          (?finish ?object))
        [])
      (_pull v (_unfold-iter seed ?object ?finish)))))
(fn read_lines [path]
  (local f (io.open path :r))
  (when (not= f nil)
    (_unfold-iter (f.lines f) f (lambda [f] (f.close f)))))

(fn concat-with [d ...]
  (table.concat [...] d))

;;; Main

(macro regex_or [...]
  (.. "'" :\<\ "(" (table.concat [...] :\|) :\ ")'"))
(local default_cnf
  {:default_keymap true
   :notify_todays_schedule true
   :notify_tomorrows_schedule true
   :hl {:GCalendarMikan {:fg :#F4511E}
        :GCalendarPeacock {:fg :#039BE5}
        :GCalendarGraphite {:fg :#616161}
        :GCalendarSage {:fg :#33B679}
        :GCalendarBanana {:fg :#f6bf26}
        :GCalendarLavender {:fg :#7986cb}
        :GCalendarTomato {:fg :#d50000}
        :GCalendarFlamingo {:fg :#e67c73}}
   :notify {"@" (λ [annex] (.. "There is a chedule: " annex))
            "#" (λ [annex] (.. "There is a memo: " annex))
            "+" (λ [annex] (.. "There is a todo: " annex))
            "-" (λ [annex] (.. "There is a remainder: " annex))
            "!" (λ [annex] (.. "There is a deadline: " annex))
            "." (λ [annex] (.. "You have completed: " annex))}
   :sche_path "none"
   :syntax {:on true
            :date {:vim_regex "\\d\\d\\d\\d/\\d\\d/\\d\\d"
                   :lua_regex "%d%d%d%d/%d%d/%d%d"
                   :vimstrftime "%Y/%m/%d"
                   }
            :month (regex_or :January :Febraury :March :April :May :June :July :August :September :October :November :December)
            :weekday (regex_or :Fri :Mon :Tue :Wed :Thu)
            :sunday "'\\<Sun\\>'"
            :saturday "'\\<Sat\\>'"}})
(local M {})
(fn _get_cnf []
  "get config"
  (local cnf (. vim.g :_sche#cnf))
  (if (= cnf nil)
    (M.setup)
    cnf))
(local create_autocmd vim.api.nvim_create_autocmd)
(local create_augroup vim.api.nvim_create_augroup)
(macro thrice-if [sentense lst]
  (fn car [x ...] x)
  (fn cdr [x ...] [...])
  (fn step [l]
    (if (= (length l) 0)
      sentense
      (let [v (car (unpack l))]
        `(if (string.match ,sentense (.. :^%s+ ,v :.*$))
           (let [kind# (string.match ,sentense (.. "^%s+(" ,v ").*$"))
                 desc# (string.match ,sentense (.. "^%s+" ,v "%s+(.*)%s*$"))]
             {kind# desc#})
           ,(step (cdr (unpack l)))))))
  (step lst))
(fn append [lst x]
  (tset lst (+ (length lst) 1) x)
  lst)
(fn pack [line list]
  (local elm (thrice-if line ["@" "#" "%+" "%-" "!" "%."]))
  (fn tbl? [o] (= (type o) "table"))
  (if (or (= list nil) (= (length list) 0) )
    (if (tbl? elm) [elm] [])
    (if (tbl? elm) (append list elm) list)))
(fn parser [b-lines]
  (local sy (. (_get_cnf) :syntax))
  (local l-date sy.date.lua_regex)
  (var ret {})
  (var date "")
  (each [_ v (ipairs b-lines)]
    (if (not= (string.match v (.. :^ l-date :.*$)) nil)
      (do
        (set date (string.match v (.. :^ l-date)))
        (tset ret date []))
      (tset ret date (pack v (. ret date)))))
  ret)
(fn syntax [group pat ...]
  (vim.cmd
    (concat-with " "
                 :syntax :match group pat ...)))
(fn set_highlight [group fg bg]
  (each [k v (pairs (. (_get_cnf) :hl))]
    (vim.api.nvim_set_hl 0 k v)))
(au! :match-hi-sche :ColorScheme
     (set_highlight))
(fn _overwrite [default_cnf cnf]
  "overwrite cnf with default_cnf
  default_cnf driven"
  (if (= (type default_cnf) :table)
    (do
      (local ret default_cnf)
      (each [k v (pairs default_cnf)]
        (if (= (type v) :table)
          (when-let new-v (. cnf k)
                    (tset ret k (_overwrite v new-v)))
          (when-let new-v (. cnf k)
                    (tset ret k new-v))))
      ret)
    (print "Err(sche.nvim): The default_cnf is not table.")))
(fn M.setup [?config]
  (if (= ?config nil)
    default_cnf
    (do
      (local cnf (_overwrite default_cnf ?config))
      (if (= cnf nil)
        default_cnf
        (do
          (tset vim.g :_sche#cnf cnf)
          cnf)))))
(fn read-data [data]
  (local notify (. (_get_cnf) :notify))
  (var ret "")
  (each [k v (pairs notify)]
    (local annex (. data k))
    (when (not= annex nil)
      (set ret (v annex))))
  ret)
(fn get-data [sd]
  (var ll [])
  (when (not= sd nil)
    (each [_ v (ipairs sd)]
      (if (= (type v) :table)
        (set ll (append ll (read-data v)))
        (set ll (append ll v)))))
  ll)
(fn do-notify [date data title]
  (local sd (. data date))
  (when (and (not= sd nil) (not= (length sd) 0))
    (local ll (get-data sd))
    ((require :notify) ll nil {:title title})))
(fn notify_todays_schedule []
  (when-let data vim.g._sche#data
            (local t (os.time))
            (local today (os.date :%Y/%m/%d t))
            (do-notify today data "Today's schedule")))
(fn notify_tomorrows_schedule []
  (when-let data vim.g._sche#data
            (local t (os.time))
            (local tomorrow (os.date :%Y/%m/%d (+ t 86400)))
            (do-notify tomorrow data "Tomorrow's schedule")))
(fn notify-main []
  (local sche_path (. (_get_cnf) :sche_path))
  (when (and (not= sche_path nil) (not= sche_path "none"))
    (local lines (read_lines sche_path))
    (when (not= lines nil)
      (local data (parser lines))
      (set vim.g._sche#data data))

    (when (. (_get_cnf) :notify_todays_schedule)
      (notify_todays_schedule))
    (when (. (_get_cnf) :notify_tomorrows_schedule)
      (notify_tomorrows_schedule))))
(au! :sche-parse [:BufWritePost :BufNewFile :BufReadPost]
     (async-do! (notify-main))
     {:pattern [:*.sche]})
(au! :sche-parse [:VimEnter]
     (when (= vim.g._sche#entered nil)
       (async-do! (notify-main))
       (set vim.g._sche#entered true)))
(var keysource {})
(set keysource ; INFO: pub
     {:goto-today (λ []
                    (local sy (. (_get_cnf) :syntax))
                    (local date sy.date.vimstrftime)
                    (local date (vim.fn.strftime (.. "^" date)))
                    (vim.fn.search date))
      :goto-tomorrow (λ []
                       (local sy (. (_get_cnf) :syntax))
                       (local date sy.date.vimstrftime)
                       (local date (vim.fn.strftime (.. "^" date) (+ (os.time) 86400)))
                       (vim.fn.search date))
      :select-mark
      (λ []
        (local item-dict {"@" :schedule
                          :- :reminder
                          :+ :todo
                          :! :deadline
                          :. :done
                          :# :note})
        (vim.ui.select
          (vim.tbl_keys item-dict)
          {:prompt "Sche built in marks"
           :format_item (lambda [item]
                          (.. item " " (. item-dict item)))}
          (λ [choice]
            (local cline (vim.api.nvim_get_current_line))
            (if (= cline "")
              (vim.api.nvim_set_current_line (.. "  " choice " "))
              (do
                (vim.cmd "normal! o")
                (vim.api.nvim_set_current_line (.. "  " choice " "))
                (vim.cmd "normal! $"))))))
      :parse-sche (λ []
                    (local lines (vim.api.nvim_buf_get_lines 0 0 -1 1))
                    (local ob (parser lines))
                    (print (vim.inspect ob)))
      :keysource-navigater (λ []
                             (local keys (vim.fn.sort (vim.tbl_keys keysource)))
                             (vim.ui.select
                               keys
                               {:prompt "Sche keysource"
                                :format_item (lambda [item] item)}
                               (λ [choice]
                                 ((. keysource choice)))))
      })

(local default_keymap
  (λ []
    (local s keysource)
    (macro desc [d]
      (.. "sche: " d))
    (epi _ k [[:n :<space><space>t
               s.goto-today
               (desc :goto-today)]
              [:n :<space><space>y
               s.goto-tomorrow
               (desc :goto-tomorrow)]
              [:n :<space><space>m
               s.select-mark
               (desc :select-mark)]
              [:n :<space><space>p
               s.parse-sche
               (desc :parse-sche)]
              [:n :<space><space>n
               s.keysource-navigater
               (desc :keysource-navigater)]
              ]
         (bmap 0 (unpack k)))))
(fn buf-setup []
  (default_keymap))
(create_autocmd
  [:BufReadPost :BufNewFile :BufWinEnter]
  {:callback (λ []
               (when (. (_get_cnf) :default_keymap)
                 (buf-setup))
               (buf-setup)
               (tset vim.bo :filetype :sche)
               (local indent 2)
               (tset vim.bo :tabstop indent)
               (tset vim.bo :shiftwidth indent)
               (tset vim.bo :softtabstop indent)
               (local sy (. (_get_cnf) :syntax))
               (local v-date sy.date.vim_regex)
               (local ftime-date sy.date.vimstrftime)
               (local syntax_on (. sy :on))
               (when syntax_on
                 (syntax :Comment "'^;.*'" )
                 (syntax :Statement sy.month)
                 (syntax :Function (.. "'^" v-date "'"))
                 (syntax :Special "'\\s*@'") ; schedule
                 (syntax :GCalendarBanana "'\\s*+'") ; todo
                 (syntax :Special "'\\s*-'") ; reminder
                 (syntax :GCalendarLavender "'\\s*#'") ; note
                 (syntax :GCalendarBanana "'\\s*+\\.'") ; done
                 (syntax :GCalendarFlamingo "'\\s*!'") ; deadline
                 (syntax :GCalendarGraphite sy.weekday)
                 (syntax :GCalendarMikan sy.sunday)
                 (syntax :GCalendarPeacock sy.saturday)
                 (syntax :GCalendarSage (vim.fn.strftime (.. "'" ftime-date "'")))))
   :pattern [:*.sche]
   :group (create_augroup :sche-syntax {:clear true})})

{: keysource
 :setup (lambda [opt]
          (M.setup opt)
          (set_highlight))
 }
