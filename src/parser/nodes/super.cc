#include "includes.h"

namespace fancy {
  namespace parser {
    namespace nodes {

      Super::Super()
      {
      }

      Super::~Super()
      {
      }
      
      FancyObject_p Super::eval(Scope *scope)
      {
        // we simply return nil, since this value isn't needed.
        // see MethodCall#eval() for dealing with super method calls.
        return nil;
      }

      OBJ_TYPE Super::type() const
      {
        return OBJ_SUPER;
      }

    }
  }
}