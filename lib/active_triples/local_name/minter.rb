module ActiveTriples
  module LocalName

    ##
    # Provide a standard interface for minting new IDs and validating
    # the ID is not in use in any known (i.e., registered) repository.
    class Minter

      ##
      # Generate a random ID that does not already exist in the
      # triplestore.
      #
      # @param [Class, #read] resource_class: The ID will be minted for
      #    an object of this class, conforming to the configurations
      #    defined in the class' resource model.
      # @param [Function, #read] minter_func: funtion to use to mint
      #    the new ID.  If not specified, the default minter function
      #    will be used to generate an UUID.
      # @param [Hash, #read] minter_args: The arguments to be passed
      #    through to the minter block, if specified.
      # @
      #
      # @return [String] the generated id
      #
      # @raise [Exception] if an available ID is not found in
      #    the maximum allowed tries.
      #
      # @TODO This is inefficient if max_tries is large. Could try
      #    multi-threading. When using the default_minter included
      #    in this class, it is unlikely to be a problem and should
      #    find an ID within the first few attempts.
      def self.generate_local_name(for_class, max_tries=10, *minter_args, &minter_block)
        raise ArgumentError, 'Argument max_tries must be >= 1 if passed in' if     max_tries    <= 0
        raise ArgumentError, 'Argument for_class must be of type class'     unless for_class.class == Class
        raise 'Requires base_uri to be defined in for_class.'               unless for_class.base_uri

        # raise ArgumentError, 'Invalid minter_block.'    unless minter_block.respond_to?(:call)
        raise ArgumentError, 'Invalid minter_block.'    if minter_block && !minter_block.respond_to?(:call)
        # raise ArgumentError, 'Invalid minter_block.'    if minter_block && !minter_block.kind_of?(Proc)
        minter_block ||= proc { default_minter }

        found   = true
        test_id = nil
        (1).upto(max_tries) do
          test_id = minter_block.call *minter_args
          found = for_class.id_persisted?(test_id)
          break unless found
        end
        raise 'Available ID not found.  Exceeded maximum tries.' if found
        test_id
      end


      ##
      # Default minter used by generate_id.
      # @param [Hash] options - not used by this minter
      # @return [String] a uuid
      def self.default_minter( *args )
        SecureRandom.uuid
      end
    end
  end
end
