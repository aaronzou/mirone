/* Copyright 2003 The MathWorks, Inc. */

/*
 * Grayscale flat dilation using a linear structuring element oriented along
 * an array dimension.  This file contains a template used by morphmex.cpp.
 *
 * Algorithm reference: M. van Herk, "A fast algorithm for local minimum
 * and maximum filters on rectangular and octagonal kernels," Pattern Recognition
 * Letters, 13:517-521, 1992.  This implementation follows the description
 * in Pierre Soille, Morphological Image Analysis: Principles and Applications,
 * 2nd ed., 89-90.
 *
 * $Revision: 1.1.8.3 $
 */

#ifndef MAX
#define MAX(a,b) ( (a) > (b) ? (a) : (b) )
#endif

/*
 * dilateWithLine performs gray scale flat dilation of a vector by a line segment.
 *
 * Input parameter f is the input vector.  It's allocated length (working_length) 
 *     must be a multiple of lambda, the length of the line segment.  If
 *     working_length > length (the original unpadded vector length), then
 *     dilateWithLine() automatically fills in the end of f with pad values as
 *     necessary.  The calling routine only has to put length values into f.
 *
 * Input parameter g is temporary working space for the algorithm.  It's allocated
 *     length must be lambda.
 *
 * Input parameter h is temporary working space for the algorithm.  It's allocated
 *     length must be lambda.
 *
 * Output parameter r is the dilated vector.  It's allocated length must be lambda.
 *
 * Input parameter pad_value is the value used to fill in f.  It is also used
 *     for values that are "past the ends" of the vectors.  For dilation it should
 *     be a value that is guaranteed to be no larger than any value in f.
 *
 * Input parameter lambda is the length (number of pixels) of the linear structuring 
 *     element.
 *
 * Input parameter origin is the origin offset, relative to the left-most pixel
 *     of the linear structuring element.
 *
 * Input parameter length is the unpadded length of f.
 *
 * Input parameter working_length is the padded length of f.  It must be a multiple
 *     of lambda.
 *
 * Notes
 * -----
 * Variable names in this routine have been chosen to match the algorithm description
 * in the Soille book (see reference above).
 *
 */
template<typename T>
void dilateWithLine(T *f, T *g, T *h, T *r, 
                    T pad_value, mwSize lambda, mwSignedIndex origin_in, 
                    mwSize length, mwSize working_length) {
    /*
     * This algorithm is taken from the description in Soille book (see above
     * reference). That reference uses a definition dilation in which
     * the structuring element is reflected about the origin, compared to the
     * definition of dilation used by the Image Processing Toolbox.  We
     * can "reflect" the linear structuring element here by adjusting the
     * origin.
     */
    mwSignedIndex origin = static_cast<mwSignedIndex>(lambda) - 1 - origin_in;

    /*
     * Insert pad values into the end of the input vector.
     */
    for (mwSize x = length; x < working_length; x++)
        f[x] = pad_value;

    /*
     * Compute g[x].
     */
    for (mwSize x = 0; x < working_length; x++)
        g[x] = ((x % lambda) == 0) ? f[x] : MAX(g[x-1], f[x]);

    /*
     * Compute h[x].
     */
    for (mwSignedIndex x = working_length-1; x >= 0; x--)
        h[x] = (((x+1) % lambda) == 0) ? f[x] : MAX(h[x+1], f[x]);

    /*
     * Compute r[x], the output vector.
     */
    mwSignedIndex g_offset = static_cast<mwSignedIndex>(lambda) - origin - 1;
    mwSignedIndex h_offset = -origin;
    for (mwSize x = 0; x < working_length; x++) {
        T v1;
        T v2;

        mwSignedIndex xg = static_cast<mwSignedIndex>(x) + g_offset;
        v1 = ((xg >= 0) && (xg < static_cast<mwSignedIndex>(working_length))) ? g[xg] : pad_value;

        mwSignedIndex xh = static_cast<mwSignedIndex>(x) + h_offset;
        v2 = ((xh >= 0) && (xh < static_cast<mwSignedIndex>(working_length))) ? h[xh] : pad_value;

        r[x] = MAX(v1, v2);
    }
}
