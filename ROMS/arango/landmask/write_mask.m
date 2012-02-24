function status=write_mask(Gname, rmask, umask, vmask, pmask);

% WRITE_SCOPE:  Writes ROMS Land/Sea masks
%
% status=write_mask(Gname,rmask,umask,vmask,pmask)
%
% This routine writes out mask data into GRID NetCDF file.
%
% On Input:
%
%    Gname       GRID NetCDF file name (character string).
%    rmask       Land/Sea mask on RHO-points (real matrix):
%                  rmask=0 land, rmask=1 Sea.
%    umask       Land/Sea mask on U-points (real matrix):
%                  umask=0 land, umask=1 Sea.
%    vmask       Land/Sea mask on V-points (real matrix):
%                  vmask=0 land, vmask=1 Sea.
%    pmask       Land/Sea mask on PSI-points (real matrix):
%                  pmask=0 land, pmask=1 Sea.
%

% svn $Id: write_mask.m 586 2012-01-03 20:19:25Z arango $
%===========================================================================%
%  Copyright (c) 2002-2012 The ROMS/TOMS Group                              %
%    Licensed under a MIT/X style license                                   %
%    See License_ROMS.txt                           Hernan G. Arango        %
%===========================================================================%

%---------------------------------------------------------------------------
% Inquire grid NetCDF file about mask variables.
%---------------------------------------------------------------------------

got.pmask=0;  define.pmask=1;  Vname.pmask='mask_psi';
got.rmask=0;  define.rmask=1;  Vname.rmask='mask_rho';
got.umask=0;  define.umask=1;  Vname.umask='mask_u';
got.vmask=0;  define.vmask=1;  Vname.vmask='mask_v';

[varnam,nvars]=nc_vname(Gname);
for n=1:nvars,
  name=deblank(varnam(n,:));
  switch name
    case {Vname.pmask}
      got.pmask=1;
      define.pmask=0;
    case {Vname.rmask}
      got.rmask=1;
      define.rmask=0;
    case {Vname.umask}
      got.umask=1;
      define.umask=0;
    case {Vname.vmask}
      got.vmask=1;
      define.vmask=0;
  end,
end,

%---------------------------------------------------------------------------
%  If appropriate, define Land/Sea mask variables.
%---------------------------------------------------------------------------

if (define.pmask | define.rmask | define.umask | define.pmask),

%  Inquire about dimensions.

  Dname.xp='xi_psi';    Dname.yp='eta_psi';
  Dname.xr='xi_rho';    Dname.yr='eta_rho';
  Dname.xu='xi_u';      Dname.yu='eta_u';
  Dname.xv='xi_v';      Dname.yv='eta_v';

  [Dnames,Dsizes]=nc_dim(Gname);
  ndims=length(Dsizes);
  for n=1:ndims,
    dimid=n-1;
    name=deblank(Dnames(n,:));
    switch name
      case {Dname.xp}
        Dsize.xp=Dsizes(n);
        did.xp=dimid;
      case {Dname.yp}
        Dsize.yp=Dsizes(n);
        did.yp=dimid;
      case {Dname.xr}
        Dsize.xr=Dsizes(n);
        did.xr=dimid;
      case {Dname.yr}
        Dsize.yr=Dsizes(n);
        did.yr=dimid;
      case {Dname.xu}
        Dsize.xu=Dsizes(n);
        did.xu=dimid;
      case {Dname.yu}
        Dsize.yu=Dsizes(n);
        did.yu=dimid;
      case {Dname.xv}
        Dsize.xv=Dsizes(n);
        did.xv=dimid;
      case {Dname.yv}
        Dsize.yv=Dsizes(n);
        did.yv=dimid;
    end,
  end,

%  Define NetCDF parameters.

  [ncglobal]=mexnc('parameter','nc_global');
  [ncdouble]=mexnc('parameter','nc_double');
  [ncfloat ]=mexnc('parameter','nc_float');
  [ncchar  ]=mexnc('parameter','nc_char');

%  Open GRID NetCDF file.

  [ncid,status]=mexnc('open',Gname,'nc_write');
  if (status ~= 0),
    disp('  ');
    disp(mexnc('strerror',status));
    error(['WRITE_MASK: OPEN - unable to open file: ', Gname]);
    return
  end,


%  Put GRID NetCDF file into define mode.

  [status]=mexnc('redef',ncid);
  if (status ~= 0),
    disp('  ');
    disp(mexnc('strerror',status));
    error(['WRITE_MASK: REDEF - unable to put into define mode.']);
    return
  end,

%  Define Land/Sea mask on RHO-points.

  if (define.rmask),
    Var.name          = Vname.rmask;
    Var.type          = ncdouble;
    Var.dimid         = [did.yr did.xr];
    Var.long_name     = 'mask on RHO-points';
    Var.flag_values   = [0.0 1.0];
    Var.flag_meanings = ['land', blanks(1), ...
                         'water'];

    [varid,status]=nc_vdef(ncid,Var);
    clear Var
  end,

%  Define Land/Sea mask on PSI-points.

  if (define.pmask),
    Var.name          = Vname.pmask;
    Var.type          = ncdouble;
    Var.dimid         = [did.yp did.xp];
    Var.long_name     = 'mask on PSI-points';
    Var.flag_values   = [0.0 1.0];
    Var.flag_meanings = ['land', blanks(1), ...
                         'water'];

    [varid,status]=nc_vdef(ncid,Var);
    clear Var
  end,

%  Define Land/Sea mask on U-points.

  if (define.umask),
    Var.name          = Vname.umask;
    Var.type          = ncdouble;
    Var.dimid         = [did.yu did.xu];
    Var.long_name     = 'mask on U-points';
    Var.flag_values   = [0.0 1.0];
    Var.flag_meanings = ['land', blanks(1), ...
                         'water'];

    [varid,status]=nc_vdef(ncid,Var);
    clear Var
  end,

%  Define Land/Sea mask on V-points.

  if (define.vmask),
    Var.name          = Vname.vmask;
    Var.type          = ncdouble;
    Var.dimid         = [did.yv did.xv];
    Var.long_name     = 'mask on V-points';
    Var.flag_values   = [0.0 1.0];
    Var.flag_meanings = ['land', blanks(1), ...
                         'water'];

    [varid,status]=nc_vdef(ncid,Var);
    clear Var
  end,

%  Leave definition mode.

  [status]=mexnc('enddef',ncid);
  if (status ~= 0),
    disp('  ');
    disp(mexnc('strerror',status));
    error(['WRITE_MASK: ENDDEF - unable to leave definition mode.']);
  end,

%  Close GRID NetCDF file.

  [status]=mexnc('close',ncid);
  if (status ~= 0),
    disp('  ');
    disp(mexnc('strerror',status));
    error(['WRITE_MASK: CLOSE - unable to close NetCDF file: ', Gname]);
  end,

end,

%---------------------------------------------------------------------------
%  Write out mask data into GRID NetCDF file.
%---------------------------------------------------------------------------

[status]=nc_write(Gname,Vname.rmask,rmask);
[status]=nc_write(Gname,Vname.pmask,pmask);
[status]=nc_write(Gname,Vname.umask,umask);
[status]=nc_write(Gname,Vname.vmask,vmask);

return