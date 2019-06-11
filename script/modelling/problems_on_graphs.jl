#' ---
#' title: Problems on Graphs
#' author: Arpit Bhatia
#' ---

#' In the mathematical discipline of graph theory, a number of problems can be solved by modelling them as optimization problems.
#' We will see some examples of such problems in the tutorial. 
#' These problems are also sometimes referred to as combinatorial optimization problems as 
#' they consist of finding an optimal object from a finite set of objects.

#' # Representing Graphs
#' For the purpose of this tutorial, we will represent graphs using adjacency matrices. 
#' An adjacency matrix, sometimes also called the connection matrix, is a square matrix used to represent a finite graph. 
#' Its rows and columns are labeled by the graph vertices, 
#' with a 1 or 0 in position ($v_{i}$,$v_{j}$) according to whether $v_{i}$ and $v_{j}$ are adjacent or not. 

#' # Maximum Matching Problem
#' Given a graph $G = (V, E)$, a matching $M \subset E$ of $G$ is a collection of vertex disjoint edges. 
#' The size of the matching $M$ is the number of edges present in $M$ i.e. $|M|$. 
#' We wish to find the Maximum matching of $G$ i.e. a matching of maximum size.
#' We can solve this problem by modelling it as an integer linear program (ILP). 
#' We define a decision variable $x_{e}$ for each edge $e \in E$ and a constraint for each vertex $u \in V$ as follows:

#' $$
#' \begin{align*}
#' \max && \sum_{e \in E} x_{e} \\
#' s.t. && \sum_{e \sim u} x_{e} \leq 1 && \forall u \in V \\
#' && x_{e} \in \{0,1\} && \forall e \in E
#' \end{align*}
#' $$

#' # Minimum Vertex Cover
#' Given a graph $G = (V, E)$, a vertex-cover $V' \subset V$ of $G$ is a collection of vertices such that 
#' each edge in $E$ is incident to at least one of the vertices in $V'$. 
#' The size of a vertex-cover $|V'|$ is the number of vertices present in the cover. 
#' We wish to find the minimum vertex cover of $G$ i.e. a minimum size vertex cover.
#' We model this problem as an ILP by defining a decision variable $y_{v}$ for each vertex $v \in V$ and 
#' a constraint for each edge $e \in E$ as follows:

#' $$
#' \begin{align*}
#' \min && \sum_{v \in V} y_{v} \\
#' s.t. && y_{u} + y_{v} \geq 1 && \forall \{u,v\} \in E \\
#' && y_{v} \in \{0,1\} && \forall v \in V
#' \end{align*}
#' $$

#' # Dominating Set
#' A dominating set in a graph $G = (V, E)$ is a set $S \subset V$ such that 
#' for each vertex $v \in V$ either $v$ or one of its neighbour should be in $S$. 
#' Note that for some vertex $u$, $u$ and its neighbour both can be present in $S$.
#' We wish to find the smallest dominating set for a graph.
#' We model this problem as an ILP by defining a decision variable $x_{v}$ for each vertex $v \in V$ along with
#' a constraint for its neighbourhood.

#' $$
#' \begin{align*}
#' \min && \sum_{v \in V} x_{v} \\
#' s.t. && \sum_{u \in N(v)}x_{u} \geq 1 && \forall v \in V \\
#' && x_{v} \in \{0,1\} && \forall v \in V
#' \end{align*}
#' $$

#' # k-Coloring Problem
#' A k-coloring of a graph $G=(V,E)$ is a function $c: V \rightarrow \{1,2...k\}$ such that 
#' $c(u) \neq c(v)$ for every edge $(u,v) \in E$. In other words, the numbers 1,2...k represent k colors, 
#' and adjacent vertices must have different colours.
#' The goal of a graph coloring problem is to find a minimum number of colours needed to colour a graph.

#' We model this problem as an ILP by defining a variable $y$ which is the number of colours we are using.
#' Given an upper bound $k$ on the number of colors needed, 
#' we use $|V| \times k$ decision variables denoting if vertex $v$ is assigned color $k$.
#' Our model will become:

#' $$
#' \begin{align*}
#' \min && y \\
#' s.t. && \sum_{i=1}^{k} x_{v,k} = 1 && \forall v \in V \\
#' && x_{v,i} = 0 && \forall v \in V, i > y \\
#' && x_{u,i} + x_{v,i} \leq 1 && \forall (u,v) \in E, i \in \{1,2...k\} \\
#' && x_{v,i} \in \{0,1\} && \forall v \in V, i \in \{1,2...k\} 
#' \end{align*}
#' $$

