#import "@preview/touying:0.6.1": *
#import themes.university: *
#import "@preview/cetz:0.3.2"
#import "@preview/fletcher:0.5.6" as fletcher: diagram, node, edge
#import fletcher.shapes: house, hexagon
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.3.2": *
#import cosmos.clouds: *
#show: show-theorion

#set text(lang: "es")

#let blob(pos, label, tint: white, ..args) = node(
  pos, align(center, label),
  width: 28mm,
  fill: tint.lighten(60%),
  stroke: 1pt + tint.darken(20%),
  corner-radius: 5pt,
  ..args,
)
// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#set text(font: "New Computer Modern")

#show: university-theme.with(
  aspect-ratio: "16-9",
  align: horizon,
  // config-common(handout: true),
  config-common(frozen-counters: (theorem-counter,)),  // freeze theorem counter for animation
  config-info(
    title: [Exploración de modelos Transformers y su Interpretabilidad
        Mecanicista],
    subtitle: [Parte 1. Interpretabilidad Mecanicista],
    author: [Hernández Peralta Sergio Antonio, Juan Emmanuel Cuéllar Lugo, \
    Julia López Diego, Nathael Ramos Cabrera],
    logo: emoji.school,
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()

== Outline <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em))

= Introducción

== A

Las redes neuronales son modelos matemáticos que actualmente poseen capacidades
impresionantes. Desde Traducción, generación de videos, creación de programas,
etc.

== Realizado
// No me gusta, cambiar púnto
- Entrenamos una red neuronal para la "ingeniería inversa" de un
  gran modelo de lenguaje.
- Creamos un sitio web con cuadernos digitales educativos

== Motivación

Black box, etc




= Formulación matemática

== Redes neuronales artificiales

#definition[
  Una _Red neuronal_ es una función paramétrica. Sus componentes principales con
  funciones lineales, y funciones de "activación", como $f(x) = max(0, x)$,
  $tanh(x)$, y entre otras. Sus entradas suelen ser vectores y las funciones de
  activación se suelen aplicar componente por componente.
]
#example[
  llama3.2, dalle, etc
]

== Entrenamiento

Para entrenar una red neuronal, usamos optimización de primer orden, es decir,
basandonos en el gradiente#pause

- Tomar la derivada de programas#pause

#pagebreak(weak:true)

Una primera idea es hacer un pequeño cambio  en cada dimensión en el espacio de
sus parámetros, pero eso costaría tantas evaluaciones como hay parámetros.
- Redes neuronales actuales tienes billones de parámetros.

#pagebreak(weak:true)

Otra idea es calcular la derivada a lapiz y papel, y luego hacer un programa
para evaluar la expresión resultante.

- Explosión en exponencial en complejidad al repetir operaciones


== Retropropagación

- Grafo asíclico dirigido

Fwd:
- Cada nodo calcula su resultado, guarda un estado interno

#pagebreak(weak:true)
Bkw:
- Multiplicación vector matriz, la matriz no se materializa siempre
- El nodo recive gradiente respecto a su salida
- Lo usa para calcular el gradiente respecto a cada entrada
- Pasa cada el $i$ esimo por su arista de entrada $i$ esimo

#pagebreak(weak:true)
#theorem[
  Sea $f: RR^n -> RR$ una función escalar computada usando un grafo
  computacional que es evaluada usando un total de $T$ operaciones elementales.
  Entonces la retropropagación computa $gradient f$ usando no mas de $6T$
  operaciones.
]
#remark[
  En la práctica, se observa de $2T$ a $3T$ en vez de $6T$.
]

== ADAM

adam cool

= Interpretabilidad mecanicista

== Fenómenos

Esta parte de aquí explica varias neuronas monosemántica y los resultados de
word2vec, las neuronas monosemánticas, y las caracteristicas en unos cuantos
bullet-points y poco texto

#speaker-note[
  En esta nota al precentador, se explica detalladamente, con mucho texto
]

== Hipótesis de reprecentaciónes Lineales

- caracteristicas como direcciones en el espacio de activaciónes


#speaker-note[
  a
]

== Compressed sensing

#lemma(title:"Johnson-Lindenstrauss")[
  #lorem(40)
]

== Autoencoders Dispersos
#lorem(2)

== auto-interpretabilidad
#lorem(3)




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
