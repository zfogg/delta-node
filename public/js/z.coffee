Delta.namespace "Z", (Z, top) ->

    # Functional tools.
    Z.Fn = Fn =
        id: (x) -> x
        array: -> arguments

        apply: (f, args...) -> f.apply @, args

        map: (f, xs) ->
            f x for x in xs

        concat: (xss) ->
            r = []
            r = r.concat xs for xs in xss
            r

        #fold :: (a -> b -> b) -> [a] -> a -> b
        fold: (f, xs, acc) ->
            if xs.length > 0
                Fn.fold f, xs.tail(), (f xs.head(), acc)
            else acc

        fold1: (f, xs) ->
            Fn.fold f, xs.tail(), xs.head()

        #zipWith :: (a -> b -> c) -> [a] -> [b] -> [c]
        zipWith: (f, xs, ys) ->
            f xs[i], ys[i] for i in [0...Math.min xs.length, ys.length]

        #zip :: [a] -> [b] -> [[a, b]]
        zip: (xs, ys) ->
            Fn.zipWith ((x, y) -> [x, y]), xs, ys

        all: (p, xs) ->
            false not in Fn.map p, xs
        any: (p, xs) ->
            for x in xs
                return true if p x
            false

        #repeat :: a -> Integer -> [a]
        repeat: (x, n) -> x for i in [0...n]

        #lookup :: (-> [a]) -> (b -> Integer) -> (b -> a)
        lookup: (table, hash = Fn.id) ->
            (x) -> table[hash x]

        #compose :: ((a -> b) || [(a -> b)])... -> (a -> b)
        compose: (args...) ->
            fs = [].concat f, fs for f in args
            (x) ->
                x = f x for f in fs.reverse().tail()
                x

        #partial :: (a... -> b... -> c) -> a... -> (b... -> c)
        partial: (f, args1...) -> (args2...) ->
            f.apply @, args1.concat args2
        #partial$ :: (a... -> b... -> c) -> [a] -> (b... -> c)
        partial$: (f, args) ->
            Fn.partial.apply @, [f].concat args
        #flip :: (a... -> b... -> c) -> b... -> (a... -> c)
        flip: (f, args1...) -> (args2...) ->
            f.apply @, (args1.concat args2).reverse()
        flip$: (f, args) ->
            Fn.flip.apply @, [f].concat args

        curry: (n, f, args...) ->
            Fn.curry$ (n - args.length), (Fn.partial$ f, args)
        curryFlip: (n, f, args...) ->
            Fn.curry$ (n - args.length), (Fn.flip$ f, args)

        curry$: (n, f, args...) ->
            if n > args.length
                Fn.partial Fn.curry$, (n - args.length), (Fn.partial$ f, args)
            else f.apply @, args

    Function::curry = (args...) ->
        Fn.curry.apply @, [@length, @].concat args
    Function::curryFlip = (args...) ->
        Fn.curryFlip.apply @, [@length, @].concat args


    Z.Math = $Math =

        PHI: 1/2*(1 + Math.sqrt 5)

        direction: (p1, p2) ->
            [p1[0] - p2[0], p1[1] - p2[1]]

        hypotenuse: (a, b) ->
            Math.sqrt a*a + b*b

        roundDigits: (n, digits) ->
            parseFloat ((Math.round \
                (n * (Math.pow 10, digits)).toFixed(digits-1)) / (Math.pow 10,digits)
            ).toFixed digits

        randomBetween: (min, max) -> Math.random() * (max - min) + min

        randomRange: (min, max) ->
            r1 = Math.round $Math.randomBetween min, max
            r2 = Math.round $Math.randomBetween min, max
            [Math.min(r1, r2) .. Math.max(r1, r2)]

        sum:     do -> Fn.partial Fn.fold1, ((x,y) -> x+y)
        product: do -> Fn.partial Fn.fold1, ((x,y) -> x*y)

        factorial: (n) ->
            $Math.product [1..n]


    # Array.prototype

    Array::head = -> @[0]
    Array::last = -> @[@length-1]

    Array::init = -> @[0..@length-2]
    Array::tail = -> @[1..]

    Array::iWhile = (p) ->
        i = 0
        i++ while p @[i]
        i
    Array::takeWhile = (p) ->
        @[0..(@iWhile p)-1]
    Array::dropWhile = (p) ->
        @[(@iWhile p)..]

    Array::take = (n) ->
        @[0...n]
    Array::drop = (n) ->
        @[n..]

    Array::toSet = ->
        s = {}
        s[x] = i for x,i in @
        @[v] for k,v of s

    Array::random = ->
        @[Math.random() * @length | 0]

    Array::extract = (keys) ->
        @map (x) ->
            for k in keys.split '.'
                x = x[k]
            x
    Array::extractf = (f, args...) ->
        @map (x) -> x[f] args

    Array::clean = ->
        @filter (x) ->
            not ($.isArray x) or x.length > 0

