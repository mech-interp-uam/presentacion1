#import "@preview/touying:0.6.1": *
#import themes.university: *
#import "@preview/cetz:0.3.2"
#import "@preview/fletcher:0.5.4" as fletcher: diagram, node, edge
#import fletcher.shapes: house, hexagon
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.3.2": *
#import cosmos.clouds: *
#show: show-theorion

#let palette = (
  "q": rgb("e6b800"),
  "k": blue,
  "v": red,
  "out": gray.darken(30%),
)
#let innerproduct(x, y) = $lr(angle.l #x, #y angle.r)$

#let sae-neuron-color = rgb("4a90e2")
#set text(lang: "es")
#let transparent = black.transparentize(100%)
#let edge-corner-radius = 0.4cm
#let node-corner-radius = 10pt

#let blob(pos, label, tint: white, hidden:false, ..args) = node(
  pos, align(center,
    if hidden {text(fill: black.transparentize(100%), label)} else {label}
  ),
  width: 175pt,
  fill: if hidden {transparent} else {tint.lighten(60%)},
  stroke: if hidden {transparent} else {1pt + tint.darken(20%)},
  corner-radius: 10pt,
  ..args,
)

#let plusnode(pos, ..args) = node(pos, $ plus.circle $, inset:-5pt, ..args)

#let edge-hidden(hidden: false, ..args) = {
  let named = args.named()
  // Solo insertar/modificar stroke si tenemos hidden
  if hidden {
    named.insert("stroke", transparent)
  }
  edge(..args.pos(), ..named)
}

// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#set text(font: "New Computer Modern")

#show: university-theme.with(
  aspect-ratio: sys.inputs.at("aspect-ratio", default:"16-9"),
  align: horizon,
  config-common(handout: sys.inputs.at("handout", default:"false") == "true"),
  config-common(frozen-counters: (theorem-counter,)),  // freeze theorem counter for animation
  config-info(
    title: [Exploración de modelos Transformers y su Interpretabilidad
        Mecanicista],
    subtitle: [Proyecto de investigación, parte 1],
    author: [Sergio Antonio Hernández Peralta, Juan Emmanuel Cuéllar Lugo, \
    Julia López Diego, Nathael Ramos Cabrera],
    logo: box(image("Logo_de_la_UAM_no_emblema.svg", width:36pt)),
  ),
  footer-a: [Sergio, Juan, Julia, Nathael],
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()

== Índice <touying:hidden>

#show outline.entry: it => block(
  below: 2.5em,
  it.indented(
    it.prefix(),
    it.body(),
  ),
)

#components.adaptive-columns(outline(
  title: none,
  indent: 1em,
  depth: 1,
))

= Introducción

== Las redes neuronales

Las redes neuronales son modelos matemáticos para aproximár funciones que
actualmente poseen capacidades impresionantes, desde traducción, generación de
videos, creación de programas, etc.

== Realizado
// No me gusta, cambiar púnto
- Entrenamos una red neuronal para la "ingeniería inversa" de los modelos
  grandes de lenguaje
- Creamos un sitio web con cuadernos digitales educativos

== Motivación

#remark[
  Las redes neuronales se utilizan para aproximar funciones, sin embargo sus
  parámetros no son naturalmente interpretables.
]




= Formulación matemática

== Redes neuronales artificiales

#definition[
  Una _Red neuronal_ es una composición de funciones paramétricas. Sus
  componentes principales son funciones lineales, y funciones de "activación",
  como $f(x) = max(0, x)$. Sus entradas suelen ser vectores y las funciones de
  activación se suelen aplicar componente por componente.
]
#example[
  llama3.2, dalle, ChatGPT, etc
]

== Perceptrones multicapa

Parámetros: $W^((l)), b^((l))$
$
  a^((0)) &= x \
  z^((l)) &= W^((l)) a^((l-1)) + b^((l)) && quad "(preactivaciones)" \
  #pause
  a^((l)) &= sigma^((l))(z^((l))) && quad "(activaciones)"
$

#pause

Por ejemplo
$
  y = sigma^((2)) (W^((2)) sigma^((1))(W^((1))x + b^((1))) + b^((2)))
$

== Activaciones y neuronas


¿Qué es una función de activación?

Una función de activación es una función $phi: RR -> RR$ usualmente no lineal,
que se aplica componente a componente al resultado de una combinación afín
$W x + b$. Es decir:
$
  phi(W x + b) = (phi(z_1), phi(z_2), ... , phi(z_n)) \ 
  "donde" quad z = W x + b
$

#pagebreak(weak: true)

La primera función de activación históricamente relevante es la función escalón,
la cual se define como:
$
  sigma(x) = cases(
    1\, "si" x >= 0,
    0\, "si" x < 0
  )
$

#pagebreak(weak: true)

La función de activación por defecto en muchas arquitecturas modernas es la
función $"ReLU"$ (Rectified Linear Unit):

$
  "ReLU"(x) = max(0, x)
$

#pagebreak(weak: true)

#show table.cell.where(y: 0): strong
#set table(
  stroke: (x, y) => if y == 0 {
    (bottom: 0.7pt + black)
  },
)

#align(
  center,
  table(
    columns: (1fr, 1fr, 1fr),
    table.header(
     [Red neuronal], [Cerebro],  [Computadora]
    ),
     [Parámetros  ], [Neuronas],  [Programa  ],
     [Activaciones], [Disparo ],  [Memoria   ],
  )
)

== Teorema de aproximación universal

#theorem(
  title: (
    "Teorema de aproximación universal"
  )
)[
  #set text(size: 20pt)
  Sea $sigma: RR -> RR$ una función no constante, acotada y continua.
  Entonces, la familia de funciones de la forma:
  $F(x) = sum_(j=1)^N alpha_j sigma(w_j^top x + theta_j)$
  es densa en $C(K)$ para cualquier conjunto compacto $K subset RR^n$.

  Es decir, para toda función $f in C(K)$ y $epsilon > 0$ existe una combinación
  finita de la forma anterior tal que: $sup_(x in K) abs(f(x) - F(x)) < epsilon$
]

#pagebreak(weak: true)

"Versión informal"

Una red neuronal feedforward con tres capas, que utilice una función de
activación no lineal adecuada, puede aproximar cualquier función continua
definida sobre un conjunto compacto de $RR^n$, con suficiente número de
neuronas.

== Entrenamiento

=== Aprendizaje supervisado
- Optimizar un modelo para aproximar una función #pause

- Los datos consisten de pares $(x,y)$ donde $y$ es aproximadamente $f(x)$ #pause

- Función objetivo

#pagebreak(weak:true)

=== Función objetivo

- Mide el desempeño #pause

- La única guía de la red neuronal #pause

Ejemplos:
#pause

- $ell_2$ #pause

- $H(p,q) = - EE_p [log q]$ (Entropía cruzada)

#pagebreak(weak:true)

#remark[
  Para entrenar una red neuronal, usamos tradicionalmente optimización de primer
  orden, es decir, basándonos en el gradiente
]

== Retropropagación

#remark[
  La retropropagación es un algoritmo para calcular el gradiente
]



== ADAM

#slide(repeat: 3, self => {
  align(center, cetz-canvas(length: 7.5cm, {
    import cetz.draw: *
    let arrow-style = fill => (
      mark: (end: "triangle", fill:fill, scale:1.1),
      stroke: 2.7pt+fill
    )

    set-transform(cetz.matrix.transform-rotate-dir(
      (1, 0.4, 0),
      (0,   0, 1),
    ))

    let n-circles = 6
    let target-opacity = 0.6
    let r = calc.root(1 - target-opacity, n-circles)
    let reduction = calc.round(r, digits: 2) * 100%
    let final_y = -0.55

    for i in range(n-circles) {
      let progress = i / (n-circles - 1)
      let size = 1-progress
      circle(
        ((1-progress)*0.14, (1- progress) * final_y),
        radius: (0.5 * size, 1.2 * size),
        fill: blue.transparentize(reduction),
        stroke: blue.transparentize(40%),
      )
    }

    let gd_color   = purple
    let sgd_color  = orange
    let adam_color = red

    let gd_points = (
      (0.1, -1.65),
      (0.09, -1.50),
      (0.07, -1.30),
      (0.04, -1.10),
      (0.0, -0.90),
      (-0.03, -0.70),
      (-0.02, -0.50),
      (0.01, -0.30),
      (0.03, -0.15),
      (0.0, 0.0)
    )
    let batch_sgd_points = (
      (0.1, -1.65),
      (0.05, -1.46),
      (-0.252, -1.20),
      (0.182, -1.00),
      (0.28, -0.80),
      (0.0, -0.60),
      (-0.14, -0.40),
      (0.0, -0.20),
      (0.14, -0.10)
    )
    let adam_points = (
      (0.1, -1.65),
      (0.05, -1.46),
      (-0.1, -1.06),
      (0.05, -0.78),
      (0.0, -0.50),
      (0.0, -0.30),
      (0.00, -0.20),
      (0.06, -0.13),
      (0.04, -0.06)
    )

    for i in range(gd_points.len() - 1) {
      line(
      gd_points.at(i),
      gd_points.at(i+1),
      ..arrow-style(
          gd_color.darken(10%).transparentize(
            if self.subslide < 1 {
              100%
            } else if self.subslide == 1 {
              0%
            } else {60%}
          )
        )
      )
    }

    for i in range(batch_sgd_points.len() - 1) {
      line(
      batch_sgd_points.at(i),
      batch_sgd_points.at(i+1),
      ..arrow-style(
          sgd_color.darken(10%).transparentize(
            if self.subslide < 2 {
              100%
            } else if self.subslide == 2 {
              0%
            } else {60%}
          )
        )
      )
    }

    for i in range(adam_points.len() - 1) {
      line(
      adam_points.at(i),
      adam_points.at(i+1),
      ..arrow-style(
          adam_color.darken(10%).transparentize(
            if self.subslide < 3 {
              100%
            } else if self.subslide == 3 {
              0%
            } else {60%}
          )
        )
      )
    }

    content((1.1,0.2), anchor: "north-west", [

      #text(fill:gd_color, [$->$ Descenso de gradiente])

      #text(
        fill:sgd_color.transparentize(if self.subslide < 2 {100%} else {0%}),
        [ $->$ Descenso de gradiente\
          #text(fill:black.transparentize(100%), $->$) Estocástico],
      )

      #text(
        fill:adam_color.transparentize(if self.subslide < 3 {100%} else {0%}),
        [$->$ ADAM],
      )
    ])

  }))
})

#speaker-note[
  - Calcular el gradiente tiene complejidad *lineal* con respecto a la cantidad
    de datos

  - Descenso de gradiente estocástico actualiza los parámetros basado en un
    gradiente calculado con solo algunos datos

  - ADAM incorpora una media movil de los momentos del gradiente
    - NO momentos como en estadística,
    - momentos en el sentído de la física
      - velocidad
      - aceleración
]


= Transformers


== Tokenización

- Tokenizar consiste en romper el texto en fragmentos #pause
  - Cada byte $->$ vocabulario de 256
  - Cada palabra $->$ vocabulario enorme
  - En la práctica, es algo intermedio

== Embedding
- A cada elemento del vocabulario se le asigna un vector (parámetro aprendible)
- Necesitamos vectores para aplicar redes neuronales

== Softmax
- Pasar de vectores a distribuciones (discretas)

$
  z &= (z_1, z_2, ..., z_T)
  #pause \
  z' &= (exp(z_1), exp(z_2), ..., exp(z_T))
$
  #pause
$
  "Softmax"(z) &= z'/norm(z')
$
#pause
Permite que las salidas sean distribuciones sobre el vocabulario

== Autoatención
#slide(repeat: 6, self => align(center, fletcher-diagram(
  edge-corner-radius: edge-corner-radius,
  node-corner-radius: node-corner-radius,
  edge-stroke: 0.1cm,
  mark-scale: 45%,
  {
    let (uncover, only, alternatives) = utils.methods(self)
    let T = 5
    let t = if self.subslide <= 5 {4} else {3}
    let spacing = 4.0cm
    let height1 = 2.7cm
    for t in range(1, T+1) {
      node(
        (t * spacing, 0cm),
        $x^((l))_#t$,
        inset: 0.6em,
        name: "x" + str(t),
      )

      let qkv = {
        node(
          (rel: (-1cm, 2.7cm), to: (name: "x" + str(t), anchor: "north")),
          $q_#t$,
          name: "q" + str(t),
        )
        node(
          (rel: (0cm, 2.7cm), to: (name: "x" + str(t), anchor: "north")),
          $k_#t$,
          name: "k" + str(t),
        )
        node(
          (rel: (1cm, 2.7cm), to: (name: "x" + str(t), anchor: "north")),
          $v_#t$,
          name: "v" + str(t),
        )

        edge(
          (name: "x" + str(t), anchor: "north"),
          (rel: (0cm, 1cm)),
          (rel: (-1cm, 0cm)),
          (rel: (0cm, 1cm)),
          stroke: palette.q,
          "-|>",
        )
        edge(
          (name: "x" + str(t), anchor: "north"),
          (rel: (0cm, 2cm)),
        stroke: palette.k,
          "-|>",
        )
        edge(
          (name: "x" + str(t), anchor: "north"),
          (rel: (0cm, 1cm)),
          (rel: (1cm, 0cm)),
          (rel: (0cm, 1cm)),
        stroke: palette.v,
          "-|>",
        )
      }

      if self.subslide == 2 {qkv} else {fletcher.hide(qkv)}
    }

    // New named code block: x4arrow
    node((rel: (0cm, 2cm), to: (name: "k" + str(t), anchor: "south")), name: "kpoint")
    // Id be nice if we could extract out from math mode the resulting distance
    // between elements so we can use it here.
    // Para esto existe la función measure, pero por performance reasons está
    // solo se puede usar en un context block, el cual limita la los cambios que
    // puedes hacer fuera de este y limita a regresar un objeto del opaco tipo
    // content. Estas limitaciones son intencinales. Por lo tanto tendríamos que
    // regresar el diagrama entero(?)
    // TODO: intentar eso, wrap el diagrama entero en context {measure etc}

    // Hardcoded extra distance for v :(
    node((rel: (1.1cm, 0cm), to: "kpoint"), name: "vpoint")
    // Hardcoded extra distance for q :(
    node((rel: (-1.1cm, 0cm), to: "kpoint"), name: "qpoint")
    let x4out = {
      edge(
        (name: "x" + str(t), anchor: "north"),
        (name: "kpoint"),
        stroke: palette.k,
        "-|>",
      )
    }

    // New named code block: x123arrows
    let x123arrows = {
      for i in range(1, t) {
        edge(
          (name: "x" + str(i), anchor: "north"),
          (name: "k" + str(i), anchor: "south"),
          (
            (name: "k" + str(i), anchor: "south"),
            "-|",
            "x" + str(t),
          ),
          // Just enogh to cover the rounded corner
          (rel: (0cm, edge-corner-radius)),
          stroke: palette.k,
          snap-to: (auto, none)
        )
      }
      for i in range(1, t+1) {
        edge(
          (name: "x" + str(i), anchor: "north"),
          (rel: (0cm, 1cm)),
          (
            (rel: (0cm, 1cm), to: (name: "x" + str(i), anchor: "north")),
            "-|",
            "vpoint",
          ),
          (name: "vpoint"),
          stroke: palette.v,
          "-|>",
        )
      }
      // Alternatives does not preserve space like in polylux (which is a BUG
      // BTW!) so let's wing it
      let alpha-extra-space-l = 2.0em // relative measure so it scales with text size
      let alpha-extra-space-r = 0.0em // relative measure so it scales with text size
      let scalar = if self.subslide == 3 {$innerproduct(q_#t, k_t)$} else {
        $#h(alpha-extra-space-l) alpha_t #h(alpha-extra-space-r)$
      }
      node(
        (rel: (-0.8cm, 0.3cm), to: "kpoint"),
        $ sum_(t <= #t) #scalar v_t $,
        inset: -1.0cm,
      )
    }

    let q-arrow = {
      edge(
        (name: "x" + str(t), anchor: "north"),
        (rel: (0cm, 1cm)),
        (
          (rel: (0cm, 1cm), to: (name: "x" + str(t), anchor: "north")),
          "-|",
          "qpoint"
        ),
        ..(if self.subslide == 3 {(
          (name: "qpoint"),
          )} else {(
          (rel: (0cm, 0.5cm), to: "qpoint"),
          (rel: (0.7cm, 0cm)),
        )}),
        stroke: rgb("e6b800"),
        "-|>",
      )
    }

    let top-arrow = {
      edge(
        (rel: (0cm, 2cm), to: (name: "kpoint")),
        (name: "r", anchor: "south"),
        snap-to: (none, none),
        stroke: palette.out,
        "-|>",
      )
    }

    let rnode = {
      node(
        (rel: (0cm, 4.5cm), to: "kpoint"),
        $r_#t$,
        inset: 0.5em,
        name: "r",
      )
    }

    // Hard coded shift so the x are aligned
    let xshift = 8.0em
    let topx = {
      node(
        (rel: (xshift, 1.1cm), to: (name: "r", anchor: "north")),
        $x^((l+1))_#t = r_#t + x^((l))_#t$,
      )
    }

    let info = node(
      (rel: (2cm, 10cm), to: "x1"),
      fill: blue.transparentize(90%),
      inset: 0.4cm,
      align(left)[
        #uncover("2-")[
          Parámetros:\
          #{
            (
              ("Q", rgb("e6b800")),
              ("K", blue),
              ("V", red),
            )
            .map(it => {
              let sym   = it.at(0)
              let color = it.at(1)
              text(fill: palette.at(lower(sym)))[$W_#sym$]
            })
            .join($, $)
          } \
          #uncover("5-", text(fill: palette.out, $W_"O"$))
        ]
      ]
    )


    // // Alpha info node, hidden by default, shown with fletcher.hide logic
    // let alpha-info = node(
    //   (rel: (2cm, 7cm), to: "x1"), // 1.5cm below info node
    //   align(left)[
    //     #set text(size: 20pt)
    //     $alpha = "Softmax"(innerproduct(q_#t, k_1), ..., innerproduct(q_#t, k_#t))$
    //   ]
    // )
    //
    // if self.subslide < 4 {fletcher.hide(alpha-info)} else {alpha-info}

    if self.subslide >= 2 {info} else {fletcher.hide(info)}
    if self.subslide >= 3 {x4out} else {fletcher.hide(x4out)}
    if self.subslide >= 3 {x123arrows} else {fletcher.hide(x123arrows)}
    if self.subslide >= 3 {q-arrow} else {fletcher.hide(q-arrow)}
    if self.subslide >= 5 {top-arrow} else {fletcher.hide(top-arrow)}
    if self.subslide >= 5 {rnode} else {fletcher.hide(rnode)}
    if self.subslide >= 5 {topx} else {fletcher.hide(topx)}

    // Node for correct bounding box so diagram does not grow this does not
    // overflow
    node((rel: (2.3cm, 0cm), to: (name: "x" + str(T))), [])
}
)))


== Autoatención Multicabezal
Cada cabezal realiza la _misma_ operación con su *propio* conjunto de parámetros
aprendibles ($W_Q, W_K, W_V, W_O$). Sus _distintas_ salidas $r$
(cada una siendo secuencia de vectores) se suman término por término.


== Bloque de Transformer
#slide(
  repeat: 3,
  self => align(center)[
    #let (only, uncover, alternatives) = utils.methods(self)

    #let edge-corner-radius = 10pt
    #let branch-off-offset = edge-corner-radius*1.4
    #let second-col-offset = 100pt
    #let before-branch = 10pt
    #fletcher-diagram(
      edge-corner-radius: edge-corner-radius,
      edge-stroke: 0.9pt,

      node((0,0), name: <xl>),
      plusnode((rel:(0pt, 117pt), to:<xl>),        name: <xlp>),
      plusnode((rel:(0pt, 117pt), to:<xlp.north>), name: <xlpp>),

      edge((rel:(0pt, -25pt), to:<xl>), <xl>, "--|>"),
      edge(<xl>, <xlp>, "-|>",
        label: $x^((l))$,
        label-pos: -9pt,
        label-side: right,
        label-sep: 18pt,
      ),
      edge(
        <xlp>,
        <xlpp>,
        label: $x^((l+1)) #uncover("2-", $= x^((l)) + sum_h h(x^((l))|"contexto")$)$,
        label-side: right,
        label-pos: -12pt,
        label-sep: 18pt,
        "-|>",
      ),
      edge(
        <xlpp>,
        (rel:(0pt, 25pt), to:<xlpp.north>),
        label: $x^((l+2)) #uncover("3-", $= x^((l+1)) + m(x^((l+1)))$)$,
        label-side: right,
        label-pos: -10pt,
        label-sep: 18pt,
        "--|>",
      ),

      node(
        enclose: (<xl>, <xlp>, <xlpp>, <mha>, <mlp>),
        fill: green.transparentize(70%),
        snap: false,
        corner-radius: 10pt,
        inset: 10pt,
        stroke: green.darken(20%),
      ),

      {
        let hidden = self.subslide < 2
        node(
          (rel:(-second-col-offset, branch-off-offset), to:<xl>),
          name:<mha-pre>,
        )
        edge-hidden(
          (<xl>, "|-", (rel:(0pt, -edge-corner-radius), to:<mha-pre>)),
          (<xl>, "|-", <mha-pre>),
          <mha-pre>,
          <mha>, "-|>",
          hidden:hidden,
        )
        blob(
          (<mha-pre>, 50%, (<mha-pre>, "|-", <xlp>)),
          [Autoatención\ multicabezal],
          tint: orange,
          name: <mha>,
          hidden: hidden,
        )
        edge-hidden(<mha>, (<mha>, "|-", <xlp>), <xlp>, "-|>",
          hidden: hidden,
        )
      },

      {
        let hidden = self.subslide < 3
        node(
          (rel:(-second-col-offset, branch-off-offset), to:<xlp.north>),
          name:<mlp-pre>,
        )
        edge-hidden(
          (<xlp>, "|-", (rel:(0pt, -edge-corner-radius), to: <mlp-pre>)),
          (<xlp>, "|-", <mlp-pre>),
          <mlp-pre>,
          <mlp>,
          hidden:hidden,
          "-|>",
        )
        blob(
          (<mlp-pre>, 50%, (<mlp-pre>, "|-", <xlpp>)),
          [Perceptrón\ Multicapa],
          tint: blue,
          name: <mlp>,
          hidden: hidden,
        )
        edge-hidden(
          <mlp>,
          (<mlp>, "|-", <xlpp>),
          <xlpp>,
          hidden: hidden,
          "-|>",
        )
      },

    )
  ]
)


== Definición
#slide(composer: (2fr, 5fr))[
  #fletcher-diagram(
    edge-corner-radius: 10pt,
    edge-stroke: 0.9pt,
    blob((0,0),  none, height:50pt, tint:green),
    blob((0,-1), none, height:50pt, tint:green),
  )
][
  #definition[
    Un transformer $"consiste"^*$ en una capa de embeding, una serie
    de bloques de transformer, y al final un $"Softmax"$
  ]
]

= Interpretabilidad mecanicista

== Fenómenos

=== Neuronas monosemánticas
La monosematicidad se refiere a un fenómeno observado en la redes neuronales donde una neurona especifica representa claramente una única característica semánticas interpretable de la entrada.
Entonces una neurona monosemántica se activa principalmente en respuesta a una sola característica de la entrada.


#pagebreak(weak: true)

Podríamos considerar una función $f: RR^n -> RR$ monosemántica en el contexto de una representación $h: X -> RR^n$, si la composición $f compose h$ depende principalmente de una única propiedad intepretable del espacio de entrada $X$

#speaker-note[
  En esta nota al precentador, se explica detalladamente, con mucho texto:
  - Mencionar las neuronas:
    - Spiderman (CLIP)
    - Halle Berry (Inception)
    - Capital cities (GPT-2)
]


#pagebreak(weak: true)

=== Polisemanticidad

La polisemanticidad es un fenómeno observado en redes neuronales profundas donde
una función escalar definida sobre una representación latente responde
simultáneamente a múltiples características semántica distintas de la entrada.

#pagebreak(weak: true)

Podríamos considerar una función $f: RR^n -> RR$ polisemántica respecto a una
representación $h: X -> RR^n$, si la composición $f compose h$ no dependte de
múltiples propiedades distintas del espacio de entradas $X$, sin que una sola de
ellas domine claramente sobre las demás.

=== Direcciónes semánticas en CLIP

En el modelo CLIP, tanto imágenes como textos se proyectan en un espacio latente
común. Dentro de este espacio, se ha observado que ciertas propiedades
semánticas —como género, número, tipo gramatical o identidad visual— se
representan mediante direcciones vectoriales específicas. \

$d_"plural" = v_"gatos" - v_"gato"$\

#speaker-note[
  Esto significa que cambios conceptuales pueden modelarse como movimientos
  lineales dentro del espacio de representación
]

#pagebreak(weak: true)

== Hipótesis de reprecentaciónes Lineales

La hipótesis de representaciones lineales propone que las propiedades aprendidas
por los modelos, ya sean semánticas o estructurales, están representadas de
forma aproximadamente lineal en los espacios latentes.\

Esto significa que, dadas las representaciones $h(x) in RR^n$ de una
entrada $x$, existe una dirección $w in RR^n$ tal que el producto escalar
$w^T h(x)$ se correlaciona fuertemente con la presencia de cierta propiedad.


#speaker-note[
  Aunque no es un teorema formal, esta hipótesis está ampliamente respaldada por
  observaciones empíricas en modelos de lenguaje, visión y multimodales.
]
#pagebreak(weak: true)
== Compressed sensing

El marco del compressed sensing ofrece una manera de recuperar representaciones
dispersas y significativas a partir de observaciones densas y aparentemente
complejas. La idea clave es que, bajo ciertas condiciones de esparsidad e
incoherencia, una señal de alta dimensión puede ser reconstruida a partir de
un número reducido de mediciones.

#speaker-note[
  En este contexto, se asume que las representaciones latentes de los modelos
  contienen una combinación de conceptos semánticos, y que para una entrada
  típica, solo unos pocos están realmente activos. Recuperar estas componentes
  latentes dispersas puede lograrse mediante técnicas de aprendizaje de
  diccionario o autoencoders dispersos.
]

#pagebreak(weak: true)

#lemma(title: "Johnson-Lindenstrauss")[
  Sea $0 < epsilon < 1$ y sea $S$ un conjunto de $m$ puntos en $RR^n$. Entonces
  existe una proyección (generalmente aleatoria) $f: RR^n -> RR^k$ con:
  $k = O(log(m)/epsilon^2)$
  tal que para todo $x, y in S$,
  $(1 - epsilon) norm(x - y)^2 <= norm(f(x) - f(y))^2 <= (1 + epsilon) norm(x - y)^2$
  Es decir, las distancias euclidianas entre los puntos se preservan
  aproximadamente bajo la proyección.
]

#speaker-note[
  La importancia de este resultado en el contexto del análisis de
  representaciones latentes radica en que nos permite proyectar vectores de alta
  dimensión a espacios de menor dimensión conservando aproximadamente sus
  distancias, lo cual facilita la recuperación de propiedades relevantes y
  respalda la idea de que, aunque las representaciones sean densas, la
  información semántica sigue siendo recuperable en dimensiones más reducidas
  sin perder su estructura fundamental.
]
#pagebreak(weak: true)

== Aprendizaje de diccionario
// TODO: Juan
#lorem(30)

== Autoencoders Dispersos
// TODO: Juan
#import "@preview/suiji:0.3.0"

#slide(composer: (auto, auto))[
  #align(center, fletcher-diagram(
    edge-corner-radius: 10pt,
    edge-stroke: 0.9pt,
    {
      let d-in = 6
      let d-hidden = 12
      let in-size = 160pt
      let hidden-size = 240pt
      let neuron-radius = 6pt
      let col-spacing = 100pt

      let rng = suiji.gen-rng(43)
      let hidden_rng = suiji.gen-rng(47)

      let (rng, activations) = suiji.uniform(rng, low: 0.0, high: 1.0, size:d-in)
      let float-to-percent = f => calc.round(f, digits:2) * 100%
      // Generador aleatorio separado para neuronas ocultas
      let p = 0.3
      let (hidden_rng, uniform-values) = suiji.uniform(hidden_rng, low: 0.0, high: 1.0, size: d-hidden)
      let is-alive = uniform-values.map(u => if u < p { 1.0 } else { 0.0 })
      let (hidden_rng, hidden-activations) = suiji.uniform(hidden_rng, low: 0.0, high: 1.0, size: d-hidden)

      // Nodo de referencia para el posicionamiento
      node((0,0), name: <center>)

      // Capa de entrada
      for i in range(d-in) {
        let y-pos = (i - d-in/2) * in-size/d-in
        node(
          (rel:(-col-spacing, y-pos), to:<center>),
          shape: circle,
          radius: neuron-radius,
          fill: sae-neuron-color.transparentize(float-to-percent(1-activations.at(i))),
          stroke: sae-neuron-color.darken(20%),
          name: label("in-" + str(i)),
        )
      }

      // Capa oculta
      for i in range(d-hidden) {
        let y-pos = (i - d-hidden/2) * hidden-size/d-hidden
        node(
          (rel:(0pt, y-pos), to:<center>),
          shape: circle,
          radius: neuron-radius,
          fill: sae-neuron-color.transparentize(float-to-percent(1 - (is-alive.at(i) * hidden-activations.at(i)))),
          stroke: sae-neuron-color.darken(20%),
          name: label("hidden-" + str(i)),
        )
      }

      // Capa de salida
      for i in range(d-in) {
        let y-pos = (i - d-in/2) * in-size/d-in
          node(
          (rel:(col-spacing, y-pos), to:<center>),
          shape: circle,
          radius: neuron-radius,
          fill: sae-neuron-color.transparentize(float-to-percent(1-activations.at(i))),
          stroke: sae-neuron-color.darken(20%),
          name: label("out-" + str(i)),
        )
      }

      // Conectar entrada con capa oculta
      for i in range(d-in) {
        for j in range(d-hidden) {
          edge(label("in-" + str(i)), label("hidden-" + str(j)), stroke: 1pt + gray)
        }
      }

      // Conectar capa oculta con salida
      for i in range(d-hidden) {
        for j in range(d-in) {
          edge(label("hidden-" + str(i)), label("out-" + str(j)), stroke: 1pt + gray)
        }
      }
    }
  ))
][
  // TODO: Juan
  - #lorem(5) #pause

  - #lorem(5) #pause

  - #lorem(5) #pause
]

== Qué es la Interpretabilidad mecanicista?

// TODO: Juan
Aquí se describe en general haciendo una analogía explicita con la ingeniería
inversa (as in computer science) y no tan explicita con la biología molecular
(por la escala pequeña de investigación) quizas solo usar palabras como crecer
(en el sentido de crecer/cultivar plantas) (las redes neuronales no se programan
explicitamente, ses crecen como plantas)

= Aprendizaje de Diccionario en llama 3.2 1B

== xd

Se entrenó un autoencoder disperso sobre las salidas del perceptrón multicapa
medio de llama3.2 1B.

Esto usando el procedimiento documentado en "GemmaScope"


== JumpReLU SAE

- Optimización con restricciones
- gradientes de esperanza
- Cosine annealing learning rate


== El SAE

#slide(composer: (1fr, 1fr))[
  $
    "JumpReLU" (accent(z, arrow) | accent(theta, arrow))
    = accent(z, arrow) dot.circle H(accent(z, arrow) - accent(theta, arrow))\
  $

  $
    diff/(diff theta) EE_(x tilde X) [cal(L)(x | theta)]
  $

  $
    cancel(diff)/(cancel(diff) theta) H(accent(z, arrow) - accent(theta, arrow))
    = 1/epsilon K((accent(z, arrow) - accent(theta, arrow))/epsilon)
  $
][
  - $(beta_1, beta_2) = (0, 0.999)$

  - Cosine schedule, warmup
  - Columnas normalizadas
  - Columnas normalizadas
  - $b = 4096$
]
