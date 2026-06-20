# Adapted from the rlang standalone S3 registration helper, trimmed to drop the optional rlang-based
# developer warning so this file has no rlang dependency.
# Source: https://github.com/r-lib/rlang/blob/main/R/standalone-s3-register.R (license: https://unlicense.org)
#
# Registers an S3 method for a generic from a suggested package (here `ggplot2::autoplot`) from `.onLoad()`.
# This is the R (>= 3.5) compatible alternative to the lazy `S3method(pkg::generic, class)` NAMESPACE
# directive, which requires R (>= 3.6).
# nocov start
s3_register = function(generic, class, method = NULL) {
  assert_string(generic)
  assert_string(class)

  pieces = strsplit(generic, "::", fixed = TRUE)[[1L]]
  assert_character(pieces, len = 2L)
  package = pieces[[1L]]
  generic = pieces[[2L]]

  caller = parent.frame()

  get_method_env = function() {
    top = topenv(caller)
    if (isNamespace(top)) {
      asNamespace(environmentName(top))
    } else {
      caller
    }
  }

  register = function(...) {
    envir = asNamespace(package)

    # Refresh the method each time, it might have been updated by `devtools::load_all()`
    method_fn = method %??% get(paste0(generic, ".", class), envir = get_method_env())
    assert_function(method_fn)

    # Only register if generic can be accessed
    if (exists(generic, envir)) {
      registerS3method(generic, class, method_fn, envir = envir)
    }
  }

  # Always register hook in case package is later unloaded & reloaded
  setHook(packageEvent(package, "onLoad"), function(...) register())

  # For compatibility with R < 4.1.0 where base isn't locked
  is_sealed = function(pkg) {
    identical(pkg, "base") || environmentIsLocked(asNamespace(pkg))
  }

  # Avoid registration failures during loading (pkgload or regular). Check that the environment is locked
  # because the registering package might be a dependency of the package that exports the generic. In that
  # case, the exports (and the generic) might not be populated yet (#1225).
  if (isNamespaceLoaded(package) && is_sealed(package)) {
    register()
  }

  invisible()
}
# nocov end
