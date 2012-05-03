class Fancy Package {
  class Handler {
    write_slots: ('user, 'repository, 'version)

    def initialize: @package_name install_path: @install_path (ENV["FANCY_PACKAGE_DIR"]) {
      set_user_repo_version

      @install_path if_nil: {
        @install_path = Fancy Package DEFAULT_PACKAGES_PATH
        Directory create!: $ Fancy Package DEFAULT_FANCY_ROOT
        Directory create!: $ Fancy Package DEFAULT_PACKAGES_PATH
        Directory create!: $ Fancy Package DEFAULT_PACKAGES_LIB_PATH
        Directory create!: $ Fancy Package DEFAULT_PACKAGES_BIN_PATH
        Directory create!: $ Fancy Package DEFAULT_PACKAGES_PATH ++ "/downloads"
      }

      @download_path = @install_path ++ "/downloads"
    }

    def load_fancypack: success_block else: else_block ({}) {
      """
      Loads the @.fancypack file within the downloaded package directory.
      If no @.fancypack file is found, raise an error.
      """

      Dir glob(installed_path ++ "/*.fancypack") first if_true: |fpackfile| {
        require: fpackfile
      }

      if: (Specification[@repository]) then: success_block else: else_block
    }

    def set_user_repo_version {
      splitted = @package_name split: "/"
      @user, @repository = splitted

      # check for version, e.g. when passing in:
      # $ fancy install bakkdoor/fyzmq=1.0.1
      splitted = @repository split: "="
      if: (splitted size > 1) then: {
        @repository, @version = splitted
        @package_name = @user + "/" + @repository
      } else: {
        @version = 'latest
      }
    }
    private: 'set_user_repo_version

    def user {
      unless: @user do: {
        set_user_repo_version
      }
      @user
    }

    def repository {
      unless: @repository do: {
        set_user_repo_version
      }
      @repository
    }

    def version {
      unless: @version do: {
        set_user_repo_version
      }
      @version
    }

    def installed_path {
      "#{@install_path}/#{@user}_#{@repository}-#{@version}"
    }

    def lib_path {
      @install_path + "/lib"
    }

    def bin_path {
      @install_path + "/bin"
    }
  }
}