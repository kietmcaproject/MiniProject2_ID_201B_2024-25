import React, { createContext, useState, useContext } from 'react';

const NavbarVisibilityContext = createContext();

export const NavbarVisibilityProvider = ({ children }) => {
  const [navbarVisible, setNavbarVisible] = useState(true);
  return (
    <NavbarVisibilityContext.Provider value={{ navbarVisible, setNavbarVisible }}>
      {children}
    </NavbarVisibilityContext.Provider>
  );
};

export const useNavbarVisibility = () => useContext(NavbarVisibilityContext);
