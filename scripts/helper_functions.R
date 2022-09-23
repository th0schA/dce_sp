# ------------------------------------------------------------------------------------------- #
# HELPER FUNCTIONS
# ------------------------------------------------------------------------------------------- #

generate_cards <- function(choice_design) {
  
  alternatives <- c("walk","bicycle","car","pt")
  alternatives_labels <- c("Walk","Bicycle","Car","PT")
  eg <- expand.grid(c("cost","traveltime"), alternatives)
  alt_attr <- sprintf('%s_%s', eg[,1], eg[,2])
  alt_attr_new <- alt_attr[!alt_attr %in% colnames(choice_design)]
  alt_attr_new <- setNames(rep(NA_character_, length(alt_attr_new)), alt_attr_new)
  
  choice_design <- dplyr::bind_cols(
    choice_design,
    dplyr::bind_rows(alt_attr_new) %>%
      dplyr::slice(rep(1:n(), each = nrow(choice_design))) %>%
      dplyr::mutate(dplyr::across(.fns = ~ tidyr::replace_na(., ""))))
  
  alt_and_attr <- stringr::str_split(alt_attr, pattern = "_",  n = 2)
  
  attributes <- unique(sapply(alt_and_attr, function(x) { x[[1]] }))
  attributes_labels <- c("Cost","Travel Time")
  
  n_cards <- nrow(choice_design)
  n_alternatives <- length(alternatives)
  n_attributes <- length(attributes)
  
  choice_data <- choice_design[, alt_attr]
  
  cards <- apply(choice_data, MARGIN = 1, function(x) {
    choice_card <- matrix(nrow = n_attributes, ncol = n_alternatives, dimnames = list(attributes, alternatives))
    choice_card[,] = x
    cc <- as.data.frame(choice_card)
  }, simplify = FALSE)
  
  cards <- lapply(seq_along(cards), function(x){
    new_card <- cards[[x]]
    colnames(new_card) <- alternatives_labels
    rownames(new_card) <- attributes_labels
    new_card
  })
  
  choice_design$cs_name <- paste0("block_",choice_design$block,"_cs_",choice_design$cs)
  names(cards) <- choice_design$cs_name
  invisible(cards)
}

randomize_card <- function(card) {
  
  cn <- colnames(card)
  n <- length(cn)
  
  scn <- sample(cn)
  card <- card[, scn]
  
  options <- sapply(seq_len(n), function(i) {glue::glue("option_{i}")})
  
  new_names <-
    sapply(seq_len(n), function(i) {
      scn <- scn[i]
      on <- glue::glue("Option {i}")
      glue::glue("{on}:\n{scn}")
    })
  
  colnames(card) <- new_names
  
  return(list(card = card, order = scn, options = options))
  
}

randomize_cards <- function(cards, seed = set.seed(1), file = NULL) {
  
  if(is.null(file)) warning("The random ordering will not be preserved! Please consider providing file argument.")
  
  seed
  
  randomized_cards <-
    sapply(seq_along(cards), function(i) {
      card <- cards[[i]]
      label <- names(cards)[[i]]
      randomize_card(card)
    }, simplify = FALSE)
  
  label <- names(cards)
  names(randomized_cards) <- label
  
  order <-
    sapply(seq_along(randomized_cards), function(i) {
      rc <- randomized_cards[[i]]
      card_name <- names(randomized_cards)[[i]]
      order <- rc$order
      options <- rc$options
      cn <- rep(card_name, length(options))
      data.frame(name = cn, order = order, options = options)
    }, simplify = FALSE)
  
  order <-
    dplyr::bind_rows(order) %>%
    tidyr::pivot_wider(names_from = options, values_from = order)
  
  # write csv
  if(!is.null(file)) {
    readr::write_csv(order, file = file.path(getwd(),"data/cards_order", paste0(file)))
    # save to global environment
    assign(paste0(stringr::str_remove(file, ".csv")), order, envir = globalenv())
  }
  
  cards <- sapply(randomized_cards, function(x) x$card, simplify = FALSE)
  
  invisible(cards)
}

print_card <- function(card, card_name, file, draw = FALSE, save = TRUE) {
  
  card <- as.data.frame(card)
  cs <- stringr::str_extract(stringr::str_extract(card_name, "cs_\\d"), "\\d")
  card <- tibble::rownames_to_column(card, var = paste0("Choice situation ",cs))
  
  nr_alts = dim(card)[2]
  nr_attr = dim(card)[1]
  
  theme <- theme_example(nr_alts, nr_attr)
  
  # apply theme to card
  c <- gridExtra::tableGrob(card, rows = NULL, theme = theme)
  
  # if draw == TRUE, draw plots on new page each
  if(draw) {
    grid::grid.newpage()
    grid::grid.draw(c)
  }
  
  w = grid::convertWidth(sum(c$widths), "in", TRUE)
  h = grid::convertHeight(sum(c$heights), "in", TRUE)
  
  if(save) ggplot2::ggsave(file, c, width = w, height = h)
  
  invisible(card)
}

print_cards <- function(cards, verbose = TRUE, ...) {
  
  sapply(seq_along(cards), function(i) {
    
    card_name <- names(cards)[[i]]
    card <- cards[[i]]
    
    file <- file.path(getwd(),"data/cards", glue::glue("{card_name}.png"))
    #file <- here::here(paste0("data/cards_batch",batchnr,"/", glue::glue("{card_name}.png")))
    
    print_card(card, card_name, file, ...)
    
    if(verbose) cat(card_name, "\n")
  })
  
  invisible(cards)
}

theme_example <- function(nr_alts, nr_attr) {
  # https://github.com/baptiste/gridextra/wiki/tableGrob
  theme_example <- gridExtra::ttheme_minimal()
  
  # head coloring
  head_colors <- c("#b3b3b3","#b1d0ff","#9ec5ff","#8dbbff","#b1d0ff")
  #head_colors <- head_colors[1:(nr_alts + 1)]
  
  # core coloring
  core_colours <- matrix("#000000", ncol = nr_alts + 1, nrow = nr_attr)
  
  # colour for attributes column
  core_colours[c(1), 1] <- "#cccccc"
  core_colours[c(2), 1] <- "#b3b3b3"
  # colour for 1. alternative
  core_colours[c(1), 2] <- "#b1d0ffa6"
  core_colours[c(2), 2] <- "#b1d0fff8"
  # colour for 2. alternative
  core_colours[c(1), 3] <- "#9ec5ffa2"
  core_colours[c(2), 3] <- "#9ec5fff8"
  # colour for 3. alternative
  core_colours[c(1), 4] <- "#8dbbffa5"
  core_colours[c(2), 4] <- "#8dbbfff8"
  # colour for 4. alternative
  core_colours[c(1), 5] <- "#b1d0ffa6"
  core_colours[c(2), 5] <- "#b1d0fff8"
  
  # text justification
  h_just_colhead <- c(0, rep(0.5, nr_alts))[1:(nr_alts + 1)]
  x_just_colhead <- c(0.05, rep(0.5, nr_alts))[1:(nr_alts + 1)]
  
  h_just_core <- matrix(c(0, rep(0.5, nr_alts)), ncol = nr_alts + 1, nrow = nr_attr, byrow = TRUE)[,1:(nr_alts + 1)]
  h_just_core <- as.vector(h_just_core)
  
  x_just_core <- matrix(c(0.05, rep(0.5, nr_alts)), ncol = nr_alts + 1, nrow = nr_attr, byrow = TRUE)[, 1:(nr_alts + 1)]
  x_just_core <- as.vector(x_just_core)
  
  theme <-
    gridExtra::ttheme_minimal(
      base_size = 14,
      colhead = list(
        fg_params = list(hjust = h_just_colhead, x = x_just_colhead),
        bg_params = list(fill = head_colors),
        padding = grid::unit(c(10, 10), "mm")
      ),
      core = list(
        fg_params = list(hjust = h_just_core, x = x_just_core),
        bg_params = list(fill = core_colours),
        padding = grid::unit(c(5, 5), "mm")
      )
    )
  
  return(theme)
}


generate_jsondata <- function(choice_design) {
  
  alternatives <- c("walk","bicycle","car","pt")
  alternatives_labels <- c("Walk","Bicycle","Car","PT")
  eg <- expand.grid(c("cost","traveltime"), alternatives)
  alt_attr <- sprintf('%s_%s', eg[,1], eg[,2])
  alt_attr_new <- alt_attr[!alt_attr %in% colnames(choice_design)]
  alt_attr_new <- setNames(rep(NA_character_, length(alt_attr_new)), alt_attr_new)
  
  choice_design <- dplyr::bind_cols(
    choice_design,
    dplyr::bind_rows(alt_attr_new) %>%
      dplyr::slice(rep(1:n(), each = nrow(choice_design))) %>%
      dplyr::mutate(dplyr::across(.fns = ~ tidyr::replace_na(., ""))))
  
  jsondata <- choice_design[, c("block", "cs", alt_attr)]
  jsondata$block_name <- paste0("block_",jsondata$block)
  return(jsondata)
}





